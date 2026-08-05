import 'current_user.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CurrentUser? currentUser;
  final bool sessionExpired;
  final bool hasCheckedSession;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentUser,
    this.sessionExpired = false,
    this.hasCheckedSession = false,
  });

  bool get isAuthenticated => currentUser != null;

  bool get isEmailUnverified {
    final user = currentUser;
    return user != null && !user.isVerified;
  }

  bool get onboardingCompleted {
    final user = currentUser;
    return user != null && user.profile.onboardingCompleted;
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    CurrentUser? currentUser,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearUser = false,
    bool? sessionExpired,
    bool? hasCheckedSession,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
      sessionExpired: sessionExpired ?? this.sessionExpired,
      hasCheckedSession: hasCheckedSession ?? this.hasCheckedSession,
    );
  }
}
