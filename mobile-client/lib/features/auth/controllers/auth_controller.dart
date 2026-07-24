import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/features/auth/models/auth_state.dart';
import 'package:mapetite/features/auth/models/register_request.dart';
import 'package:mapetite/features/auth/models/register_response.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/services/setup_service.dart';

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

      final currentUser = await _authService.getCurrentUser();

      state = AuthState(
        isLoading: false,
        successMessage: 'Signed in successfully.',
        currentUser: currentUser,
      );

      return true;
    } on AppException catch (error) {
      await AuthTokenService.clearTokens();

      state = AuthState(
        isLoading: false,
        errorMessage: error.statusCode == 401
            ? 'Invalid email or password.'
            : error.message,
      );

      return false;
    } catch (_) {
      await AuthTokenService.clearTokens();

      state = const AuthState(
        isLoading: false,
        errorMessage: 'Unexpected error occurred. Please try again.',
      );

      return false;
    }
  }

  Future<bool> loadCurrentUser() async {
    if (!AuthTokenService.hasTokens) {
      state = state.copyWith(clearUser: true);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUser = await _authService.getCurrentUser();

      state = AuthState(
        isLoading: false,
        currentUser: currentUser,
      );

      return true;
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await AuthTokenService.clearTokens();

        state = const AuthState(
          isLoading: false,
        );

        return false;
      }

      state = AuthState(
        isLoading: false,
        errorMessage: error.message,
        currentUser: state.currentUser,
      );

      return false;
    } catch (_) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Unable to load your session. Please try again.',
        currentUser: state.currentUser,
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

  Future<bool> resendVerificationEmail() async {
    final email = state.currentUser?.email;

    if (email == null || email.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Unable to resend verification email.',
      );

      return false;
    }

    try {
      final message = await _authService.resendVerificationEmail(email);

      state = state.copyWith(
        successMessage: message,
        clearError: true,
      );

      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        errorMessage: error.message,
        clearSuccess: true,
      );

      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to resend verification email.',
        clearSuccess: true,
      );

      return false;
    }
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