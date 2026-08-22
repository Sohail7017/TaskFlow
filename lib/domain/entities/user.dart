/// User domain entity
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
}
