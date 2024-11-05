class AdminRegister {
  String name;
  String email;
  String username;
  String password;
  String phone;
  String address;
  String details;
  String roleId;

  AdminRegister({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.phone,
    required this.address,
    required this.details,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'phone': phone,
      'address': address,
      'details': details,
      'role_id': roleId,
    };
  }
}
