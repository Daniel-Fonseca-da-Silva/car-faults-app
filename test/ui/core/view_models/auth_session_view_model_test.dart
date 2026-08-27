import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
  photoUrl: 'https://example.com/photo.png',
);

void main() {
  test('starts signed out', () {
    final viewModel = AuthSessionViewModel();

    expect(viewModel.user, isNull);
    expect(viewModel.isSignedIn, isFalse);
  });

  test('setUser stores the user, flips isSignedIn and notifies', () {
    final viewModel = AuthSessionViewModel();
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.setUser(_user);

    expect(viewModel.user, _user);
    expect(viewModel.isSignedIn, isTrue);
    expect(notifications, 1);
  });

  test('signOut clears the user and notifies', () {
    final viewModel = AuthSessionViewModel()..setUser(_user);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.signOut();

    expect(viewModel.user, isNull);
    expect(viewModel.isSignedIn, isFalse);
    expect(notifications, 1);
  });
}
