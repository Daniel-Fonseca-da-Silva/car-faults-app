import 'package:car_faults_app/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson maps avatarUrl to photoUrl', () {
    final user = User.fromJson({
      'id': 'u1',
      'name': 'Ada Lovelace',
      'email': 'ada@example.com',
      'avatarUrl': 'https://example.com/ada.png',
    });

    expect(user.id, 'u1');
    expect(user.name, 'Ada Lovelace');
    expect(user.email, 'ada@example.com');
    expect(user.photoUrl, 'https://example.com/ada.png');
  });

  test('fromJson allows a null avatarUrl', () {
    final user = User.fromJson({
      'id': 'u2',
      'name': 'Grace',
      'email': 'grace@example.com',
      'avatarUrl': null,
    });

    expect(user.photoUrl, isNull);
  });
}
