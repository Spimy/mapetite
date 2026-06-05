class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {'token': 'mock_token_12345', 'userId': 'user_001'};
    // TODO: Replace with real API call to POST /api/v1/auth/login
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {'token': 'mock_token_new', 'userId': 'user_002'};
    // TODO: Replace with real API call to POST /api/v1/auth/register
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Call POST /api/v1/auth/logout and clear stored token
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: Call POST /api/v1/auth/forgot-password
  }
}
