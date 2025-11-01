class AppUser {
  final String id;
  final String email;
  final String userName;
  final String? role;

  AppUser({
    required this.id,
    required this.email,
    required this.userName,
    this.role,
  });
}
