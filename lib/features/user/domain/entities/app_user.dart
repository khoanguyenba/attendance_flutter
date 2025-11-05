class AppUser {
  final String id;
  final String userName;
  final String email;
  final String role;
  final String employeeId;

  AppUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    required this.employeeId,
  });

  @override
  String toString() {
    return 'AppUser{id: $id, userName: $userName, email: $email, role: $role, employeeId: $employeeId}';
  }
}
