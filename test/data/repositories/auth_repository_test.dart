import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/services/auth_api_service.dart';
import 'package:car_faults_app/data/services/google_auth_service.dart';
import 'package:car_faults_app/data/services/secure_token_storage.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage extends SecureTokenStorage {
  _FakeTokenStorage([this.token]);

  String? token;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}

class _FakeGoogleAuthService extends GoogleAuthService {
  _FakeGoogleAuthService({this.idToken, this.signInError, this.signOutError});

  final String? idToken;
  final Object? signInError;
  final Object? signOutError;
  var signOutCalls = 0;

  @override
  Future<String?> signIn() async {
    if (signInError != null) throw signInError!;
    return idToken;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError != null) throw signOutError!;
  }
}

class _FakeAuthApiService extends AuthApiService {
  _FakeAuthApiService({
    this.session,
    this.loginError,
    this.currentUser,
    this.fetchError,
    this.logoutError,
  }) : super(dio: Dio());

  final ({String accessToken, User user})? session;
  final DioException? loginError;
  final User? currentUser;
  final Object? fetchError;
  final Object? logoutError;
  var logoutCalls = 0;

  @override
  Future<({String accessToken, User user})> loginWithGoogle(
    String idToken,
  ) async {
    if (loginError != null) throw loginError!;
    return session!;
  }

  @override
  Future<User> fetchCurrentUser() async {
    if (fetchError != null) throw fetchError!;
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    if (logoutError != null) throw logoutError!;
  }
}

const _sampleUser = User(
  id: 'user-1',
  name: 'Ada',
  email: 'ada@example.com',
  photoUrl: 'https://example.com/a.png',
);

void main() {
  test('signInWithGoogle returns null when the user cancels', () async {
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(idToken: null),
      authApiService: _FakeAuthApiService(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(await repository.signInWithGoogle(), isNull);
  });

  test('signInWithGoogle saves the token and returns AuthSuccess', () async {
    final storage = _FakeTokenStorage();
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(idToken: 'google-token'),
      authApiService: _FakeAuthApiService(
        session: (accessToken: 'jwt-token', user: _sampleUser),
      ),
      tokenStorage: storage,
    );

    final result = await repository.signInWithGoogle();

    expect(result, isA<AuthSuccess>());
    expect((result as AuthSuccess).user.id, _sampleUser.id);
    expect(storage.token, 'jwt-token');
  });

  test('signInWithGoogle maps DioException with response to server', () async {
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(idToken: 'google-token'),
      authApiService: _FakeAuthApiService(
        loginError: DioException(
          requestOptions: RequestOptions(path: '/v1/auth/google/mobile'),
          response: Response(
            requestOptions: RequestOptions(path: '/v1/auth/google/mobile'),
            statusCode: 500,
          ),
        ),
      ),
      tokenStorage: _FakeTokenStorage(),
    );

    final result = await repository.signInWithGoogle();

    expect(result, isA<AuthFailure>());
    expect((result as AuthFailure).reason, AuthFailureReason.server);
  });

  test(
    'signInWithGoogle maps DioException without response to network',
    () async {
      final repository = AuthRepository(
        googleAuthService: _FakeGoogleAuthService(idToken: 'google-token'),
        authApiService: _FakeAuthApiService(
          loginError: DioException(
            requestOptions: RequestOptions(path: '/v1/auth/google/mobile'),
            type: DioExceptionType.connectionError,
          ),
        ),
        tokenStorage: _FakeTokenStorage(),
      );

      final result = await repository.signInWithGoogle();

      expect((result as AuthFailure).reason, AuthFailureReason.network);
    },
  );

  test('signInWithGoogle maps unknown errors', () async {
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(
        signInError: StateError('plugin failed'),
      ),
      authApiService: _FakeAuthApiService(),
      tokenStorage: _FakeTokenStorage(),
    );

    final result = await repository.signInWithGoogle();

    expect((result as AuthFailure).reason, AuthFailureReason.unknown);
  });

  test('restoreSession returns null when there is no token', () async {
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(),
      authApiService: _FakeAuthApiService(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(await repository.restoreSession(), isNull);
  });

  test(
    'restoreSession returns the current user when the token is valid',
    () async {
      final repository = AuthRepository(
        googleAuthService: _FakeGoogleAuthService(),
        authApiService: _FakeAuthApiService(currentUser: _sampleUser),
        tokenStorage: _FakeTokenStorage('jwt'),
      );

      final user = await repository.restoreSession();
      expect(user?.id, _sampleUser.id);
      expect(user?.email, _sampleUser.email);
    },
  );

  test('restoreSession clears the token when fetch fails', () async {
    final storage = _FakeTokenStorage('jwt');
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(),
      authApiService: _FakeAuthApiService(fetchError: Exception('expired')),
      tokenStorage: storage,
    );

    expect(await repository.restoreSession(), isNull);
    expect(storage.token, isNull);
  });

  test('signOut clears local token even when remote calls fail', () async {
    final storage = _FakeTokenStorage('jwt');
    final google = _FakeGoogleAuthService(signOutError: Exception('offline'));
    final api = _FakeAuthApiService(logoutError: Exception('offline'));
    final repository = AuthRepository(
      googleAuthService: google,
      authApiService: api,
      tokenStorage: storage,
    );

    await repository.signOut();

    expect(api.logoutCalls, 1);
    expect(google.signOutCalls, 1);
    expect(storage.token, isNull);
  });

  test('deleteAccount returns AuthComingSoon', () async {
    final repository = AuthRepository(
      googleAuthService: _FakeGoogleAuthService(),
      authApiService: _FakeAuthApiService(),
      tokenStorage: _FakeTokenStorage(),
    );

    expect(await repository.deleteAccount(), isA<AuthComingSoon>());
  });
}
