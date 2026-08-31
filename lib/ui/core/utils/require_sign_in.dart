import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/login/views/login_view.dart';
import '../view_models/auth_session_view_model.dart';

/// Gates an action (saving, commenting, voting) behind Google sign-in.
///
/// Runs [onSignedIn] immediately if the user already has a session.
/// Otherwise it opens the login screen first and, only if that sign-in
/// succeeds, runs [onSignedIn] right after — so the person continues the
/// action they originally tapped instead of having to tap it again.
Future<void> requireSignIn(
  BuildContext context,
  VoidCallback onSignedIn,
) async {
  final session = context.read<AuthSessionViewModel>();
  if (session.isSignedIn) {
    onSignedIn();
    return;
  }

  await pushLoginView(context);

  if (context.mounted && session.isSignedIn) {
    onSignedIn();
  }
}
