class RegisterRequest {
  final String username;
  final String email;
  final String password1;
  final String password2;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password1,
    required this.password2,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password1': password1,
      'password2': password2,
    };
  }
}
