class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = num.tryParse(value);
    if (n == null) return '$fieldName must be a number';
    if (n <= 0) return '$fieldName must be greater than zero';
    return null;
  }

  static String? quantity(String? value, {int? max}) {
    final base = positiveNumber(value, fieldName: 'Quantity');
    if (base != null) return base;
    final n = int.parse(value!.trim());
    if (max != null && n > max) return 'Quantity cannot exceed $max';
    return null;
  }

  static String? futureDate(DateTime? value) {
    if (value == null) return 'Deadline is required';
    if (value.isBefore(DateTime.now())) return 'Deadline must be a future date';
    return null;
  }
}
