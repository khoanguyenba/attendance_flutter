class AssignRoleCommand {
  final String userId;
  final String role;

  AssignRoleCommand({required this.userId, required this.role});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'role': role};
  }
}
