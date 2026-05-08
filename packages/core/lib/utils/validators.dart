/// Input validators for form fields
abstract final class Validators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final _digitRegex = RegExp(r'[0-9]');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  static final _phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,20}$');
  static final _lowercaseRegex = RegExp(r'[a-z]');
  static final _uppercaseRegex = RegExp(r'[A-Z]');

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validates password with specific requirements
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_digitRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates name (non-empty, minimum 2 characters)
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  /// Validates phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (!_phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates password match for confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Checks if terms are accepted
  static String? termsAccepted(bool? accepted) {
    if (accepted != true) {
      return 'You must accept the terms and conditions';
    }

    return null;
  }
}

/// Password strength levels
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Calculates password strength
PasswordStrength calculatePasswordStrength(String? password) {
  if (password == null || password.isEmpty) {
    return PasswordStrength.empty;
  }

  int score = 0;

  // Length checks
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (password.length >= 16) score++;

  // Character type checks
  if (Validators._lowercaseRegex.hasMatch(password)) score++;
  if (Validators._uppercaseRegex.hasMatch(password)) score++;
  if (Validators._digitRegex.hasMatch(password)) score++;
  if (Validators._specialCharRegex.hasMatch(password)) score++;

  if (score <= 2) return PasswordStrength.weak;
  if (score <= 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}