class AdminLogin {
  String username;
  String password;

  AdminLogin({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
