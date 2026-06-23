import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/services/setup_service.dart';
import '../models/auth_state.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final response = await _authService.register(
        RegisterRequest(
          username: username.trim(),
          email: email.trim(),
          password1: password,
          password2: confirmPassword,
        ),
      );

      await SetupService.savePendingUserInfo(
        name: fullName.trim(),
        email: email.trim(),
      );

      state = AuthState(
        isLoading: false,
        successMessage: response.detail,
      );

      return true;
    } on AppException catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: error.message,
      );

      return false;
    } on FormatException catch (_) {
      state = const AuthState(
        isLoading: false,
        errorMessage:
            'The server returned an invalid response. Please try again.',
      );

      return false;
    } catch (_) {
      state = const AuthState(
        isLoading: false,
        errorMessage:
            'Registration failed unexpectedly. Please try again.',
      );

      return false;
    }
  }
}