import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/features/auth/models/auth_state.dart';
import 'package:mapetite/features/auth/models/register_request.dart';
import 'package:mapetite/features/auth/models/register_response.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';
import 'package:mapetite/shared/services/setup_service.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(authServiceProvider));
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final tokens = await _authService.login(
        email: email.trim(),
        password: password,
      );

      await AuthTokenService.saveTokens(tokens);

      state = const AuthState(
        isLoading: false,
        successMessage: 'Signed in successfully.',
      );

      return true;
    } on AppException catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: error.statusCode == 401
            ? 'Invalid email or password.'
            : error.message,
      );

      return false;
    } catch (_) {
      state = const AuthState(
        isLoading: false,
        errorMessage: 'Unexpected error occurred. Please try again.',
      );

      return false;
    }
  }

  Future<void> logout() async {
    await AuthTokenService.clearTokens();

    state = const AuthState(
      successMessage: 'Signed out successfully.',
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password1,
    required String password2,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final result = await _authService.register(
        RegisterRequest(
          username: username.trim(),
          email: email.trim(),
          password1: password1,
          password2: password2,
        ),
      );

      switch (result) {
        case RegisterSuccess():
          await SetupService.savePendingUserInfo(
            username: username.trim(),
            email: email.trim(),
          );

          state = AuthState(isLoading: false, successMessage: result.detail);
          return true;

        case RegisterError():
          state = AuthState(
            isLoading: false,
            errorMessage: result.error.displayMessage,
          );
          return false;
      }
    } on AppException catch (error) {
      // The Service already caught 400s and turned them into RegisterErrors.
      // Reaching here means it's a Timeout, No Internet, or 500 error.
      state = AuthState(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = const AuthState(
        isLoading: false,
        errorMessage: 'Unexpected error occurred. Please try again.',
      );
      return false;
    }
  }
}
