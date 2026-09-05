import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/user.dart';
import '../services/api_client.dart';
import '../services/auth_api_service.dart';
import '../services/google_auth_service.dart';
import '../services/secure_token_storage.dart';
import '../services/users_api_service.dart';

/// Outcome of a Google sign-in attempt or another auth command.
sealed class AuthResult {
  const AuthResult();
}

/// Google sign-in succeeded; [user] is now authenticated.
class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);
  final User user;
}

/// Why a Google sign-in attempt failed.
enum AuthFailureReason { network, server, unknown }

/// Google sign-in failed with [reason]; the View maps it to a message.
class AuthFailure extends AuthResult {
  const AuthFailure(this.reason);
  final AuthFailureReason reason;
}

/// Outcome of [AuthRepository.deleteAccount].
sealed class DeleteAccountResult {
  const DeleteAccountResult();
}

/// The account was deleted and the local session cleared.
class DeleteAccountSuccess extends DeleteAccountResult {
  const DeleteAccountSuccess();
}

class DeleteAccountFailure extends DeleteAccountResult {
  const DeleteAccountFailure();
}

/// Owns the Google sign-in flow and the resulting session: exchanging the
/// Google ID token for the API's JWT, persisting it securely, and
/// restoring/clearing the session across app launches.
class AuthRepository {
  /// Builds the real dependency graph by default: native Google Sign-In, a
  /// Dio client pointed at `car-faults-api` with the stored JWT attached to
  /// every request, and secure on-device token storage.
  ///
  /// Every parameter can be overridden — tests subclass [AuthRepository]
  /// and override individual methods instead of injecting fakes here, but
  /// the seam is kept for callers that do want to swap a dependency.
  ///
  /// [onUnauthorized] runs whenever the API rejects the stored token (401),
  /// so the caller can clear the session shown in the UI.
  AuthRepository({
    GoogleAuthService? googleAuthService,
    AuthApiService? authApiService,
    UsersApiService? usersApiService,
    SecureTokenStorage? tokenStorage,
    VoidCallback? onUnauthorized,
  }) : _googleAuthService = googleAuthService ?? GoogleAuthService(),
       _authApiService =
           authApiService ??
           AuthApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
               onUnauthorized: onUnauthorized,
             ),
           ),
       _usersApiService =
           usersApiService ??
           UsersApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
               onUnauthorized: onUnauthorized,
             ),
           ),
       _tokenStorage = tokenStorage ?? SecureTokenStorage();

  final GoogleAuthService _googleAuthService;
  final AuthApiService _authApiService;
  final UsersApiService _usersApiService;
  final SecureTokenStorage _tokenStorage;

  /// Runs the Google sign-in flow and exchanges the ID token with the API.
  ///
  /// Returns `null` if the user cancels before completing sign-in.
  Future<AuthResult?> signInWithGoogle() async {
    try {
      final idToken = await _googleAuthService.signIn();
      if (idToken == null) return null;

      final session = await _authApiService.loginWithGoogle(idToken);
      await _tokenStorage.saveToken(session.accessToken);
      return AuthSuccess(session.user);
    } on DioException catch (e) {
      return AuthFailure(
        e.response != null
            ? AuthFailureReason.server
            : AuthFailureReason.network,
      );
    } catch (_) {
      return const AuthFailure(AuthFailureReason.unknown);
    }
  }

  /// Restores a previous session from the stored JWT.
  ///
  /// Returns `null`, and clears the token, if there is none or it is no
  /// longer valid.
  Future<User?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;

    try {
      return await _authApiService.fetchCurrentUser();
    } catch (_) {
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  /// Revokes the server-side session, then clears the stored token and the
  /// Google Sign-In session.
  ///
  /// Revoking the API token and the Google session are both best-effort so
  /// a transient plugin/network failure never leaves the app stuck showing
  /// a signed-in state the user just asked to leave — the local token is
  /// cleared regardless of whether either call succeeds.
  Future<void> signOut() async {
    try {
      await _authApiService.logout();
    } catch (_) {
      // Best-effort — local session is still cleared below.
    }
    await _tokenStorage.deleteToken();
    try {
      await _googleAuthService.signOut();
    } catch (_) {
      // Best-effort — local session is already cleared regardless.
    }
  }

  /// Deletes the signed-in account via `DELETE /v1/users/me`.
  ///
  /// On success, clears the local token and the Google Sign-In session —
  /// both best-effort, mirroring [signOut] — so the caller can drop the
  /// signed-in state shown in the UI regardless of whether either succeeds.
  Future<DeleteAccountResult> deleteAccount() async {
    try {
      await _usersApiService.deleteMe();
    } on DioException {
      return const DeleteAccountFailure();
    }

    await _tokenStorage.deleteToken();
    try {
      await _googleAuthService.signOut();
    } catch (_) {
      // Best-effort — the account is already deleted and the local token
      // cleared regardless.
    }
    return const DeleteAccountSuccess();
  }
}
