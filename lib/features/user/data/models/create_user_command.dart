class CreateUserCommand {
  final String userName;
  final String password;
  final String employeeId;

  CreateUserCommand({
    required this.userName,
    required this.password,
    required this.employeeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'employeeId': employeeId,
    };
  }
}
