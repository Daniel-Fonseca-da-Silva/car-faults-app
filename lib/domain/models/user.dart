/// Signed-in account shown in the navigation drawer.
///
/// [photoUrl] comes from Google and may be absent, in which case the UI
/// falls back to the user's initials.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  /// Builds a [User] from `car-faults-api`'s `UserResponseDto` JSON.
  ///
  /// The API's field is named `avatarUrl`; this app calls it [photoUrl].
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['avatarUrl'] as String?,
    );
  }
}
