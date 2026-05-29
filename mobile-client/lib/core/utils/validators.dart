abstract class Validators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    final regex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid phone number.';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return '$field must be a positive number.';
    return null;
  }

  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength++;
    return strength;
  }
}
