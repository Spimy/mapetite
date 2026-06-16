class RegisterResponse {
  final String detail;

  const RegisterResponse({
    required this.detail,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      detail: json['detail'] as String? ?? 'Registration successful.',
    );
  }
}