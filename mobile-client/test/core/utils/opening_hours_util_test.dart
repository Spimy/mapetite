import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/utils/opening_hours_util.dart';

void main() {
  group('computeOpenStatus', () {
    test('closed today returns isOpen false', () {
      final now = DateTime(2026, 7, 16, 14, 0);
      final todayIndex = now.weekday - 1;
      final hours = [
        OperatingHourModel(dayOfWeek: todayIndex, isClosed: true),
      ];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isFalse);
      expect(status.closingTimeLabel, 'Closed');
    });

    test('open today, current time within hours returns isOpen true with formatted closing time', () {
      final now = DateTime(2026, 7, 16, 14, 0);
      final todayIndex = now.weekday - 1;
      final hours = [
        OperatingHourModel(
          dayOfWeek: todayIndex,
          isClosed: false,
          openTime: '09:30:00',
          closeTime: '22:00:00',
        ),
      ];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isTrue);
      expect(status.closingTimeLabel, '10:00 PM');
    });

    test('open today, but current time after closing returns isOpen false', () {
      final now = DateTime(2026, 7, 16, 23, 0);
      final todayIndex = now.weekday - 1;
      final hours = [
        OperatingHourModel(
          dayOfWeek: todayIndex,
          isClosed: false,
          openTime: '09:30:00',
          closeTime: '22:00:00',
        ),
      ];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isFalse);
      expect(status.closingTimeLabel, 'Closed');
    });

    test('open today, current time before opening returns isOpen false', () {
      final now = DateTime(2026, 7, 16, 7, 0);
      final todayIndex = now.weekday - 1;
      final hours = [
        OperatingHourModel(
          dayOfWeek: todayIndex,
          isClosed: false,
          openTime: '09:30:00',
          closeTime: '22:00:00',
        ),
      ];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isFalse);
    });

    test('overnight hours (close time past midnight) still counts as open', () {
      final now = DateTime(2026, 7, 16, 1, 0);
      final todayIndex = now.weekday - 1;
      final hours = [
        OperatingHourModel(
          dayOfWeek: todayIndex,
          isClosed: false,
          openTime: '18:00:00',
          closeTime: '02:00:00',
        ),
      ];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isTrue);
    });

    test('no entry for today returns isOpen false', () {
      final now = DateTime(2026, 7, 16, 14, 0);
      final hours = <OperatingHourModel>[];

      final status = computeOpenStatus(hours, now);

      expect(status.isOpen, isFalse);
      expect(status.closingTimeLabel, 'Closed');
    });

    test('OperatingHourModel.fromJson maps the real API shape', () {
      final model = OperatingHourModel.fromJson({
        'day_of_week': 0,
        'day_name': 'Monday',
        'open_time': '09:30:00',
        'close_time': '22:00:00',
        'is_closed': false,
      });

      expect(model.dayOfWeek, 0);
      expect(model.isClosed, isFalse);
      expect(model.openTime, '09:30:00');
      expect(model.closeTime, '22:00:00');
    });
  });
}
