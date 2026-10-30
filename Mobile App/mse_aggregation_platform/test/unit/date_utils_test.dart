import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('formatDate handles null and valid date', () {
      expect(AppDateUtils.formatDate(null), '-');
      final dt = DateTime(2026, 9, 21);
      expect(AppDateUtils.formatDate(dt), contains('2026'));
      expect(AppDateUtils.formatDate(dt), contains('Sep'));
    });

    test('formatDateTime handles null and valid datetime', () {
      expect(AppDateUtils.formatDateTime(null), '-');
      final dt = DateTime(2026, 9, 21, 14, 30);
      expect(AppDateUtils.formatDateTime(dt), contains('2026'));
    });

    test('isExpired works correctly for past and future', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(AppDateUtils.isExpired(past), isTrue);
      expect(AppDateUtils.isExpired(future), isFalse);
    });

    test('timeRemaining returns Expired for past dates', () {
      final past = DateTime.now().subtract(const Duration(days: 2));
      expect(AppDateUtils.timeRemaining(past), 'Expired');
    });

    test('timeRemaining returns remaining days for future dates', () {
      final future = DateTime.now().add(const Duration(days: 5, hours: 2));
      expect(AppDateUtils.timeRemaining(future), contains('d remaining'));
    });
  });
}
