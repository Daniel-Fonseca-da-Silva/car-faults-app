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
}
