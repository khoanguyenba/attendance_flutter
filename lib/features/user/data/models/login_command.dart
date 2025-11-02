class LoginCommand {
  final String userName;
  final String password;

  LoginCommand({required this.userName, required this.password});

  Map<String, dynamic> toJson() {
    return {'userName': userName, 'password': password};
  }
}
