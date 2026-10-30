import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error for null or empty string', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
    });

    test('returns error for invalid email format', () {
      expect(Validators.email('invalid'), 'Enter a valid email address');
      expect(Validators.email('test@'), 'Enter a valid email address');
      expect(Validators.email('test@domain'), 'Enter a valid email address');
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('admin@mse.org'), isNull);
      expect(Validators.email('first.last@company.co.in'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for null or empty string', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error for short password', () {
      expect(Validators.password('12345'), 'Password must be at least 6 characters');
    });

    test('returns null for valid password', () {
      expect(Validators.password('secret123'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when empty', () {
      expect(Validators.confirmPassword(null, 'secret'), 'Please confirm your password');
      expect(Validators.confirmPassword('', 'secret'), 'Please confirm your password');
    });

    test('returns error when mismatching', () {
      expect(Validators.confirmPassword('secret2', 'secret1'), 'Passwords do not match');
    });

    test('returns null when matching', () {
      expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });

  group('Validators.required', () {
    test('returns error when empty', () {
      expect(Validators.required(null, fieldName: 'Name'), 'Name is required');
      expect(Validators.required('  ', fieldName: 'Business Name'), 'Business Name is required');
    });

    test('returns null when valid', () {
      expect(Validators.required('Acme Corp', fieldName: 'Business Name'), isNull);
    });
  });

  group('Validators.quantity', () {
    test('validates positive number', () {
      expect(Validators.quantity(null), 'Quantity is required');
      expect(Validators.quantity('abc'), 'Quantity must be a number');
      expect(Validators.quantity('0'), 'Quantity must be greater than zero');
      expect(Validators.quantity('-5'), 'Quantity must be greater than zero');
    });

    test('validates maximum bound', () {
      expect(Validators.quantity('150', max: 100), 'Quantity cannot exceed 100');
      expect(Validators.quantity('100', max: 100), isNull);
      expect(Validators.quantity('50', max: 100), isNull);
    });
  });

  group('Validators.futureDate', () {
    test('returns error for null', () {
      expect(Validators.futureDate(null), 'Deadline is required');
    });

    test('returns error for past date', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(Validators.futureDate(past), 'Deadline must be a future date');
    });

    test('returns null for future date', () {
      final future = DateTime.now().add(const Duration(days: 7));
      expect(Validators.futureDate(future), isNull);
    });
  });
}
