import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_pro/features/subscription/domain/reminder_type.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_plan.dart';

void main() {
  group('ReminderType', () {
    test('daysBeforeExpiry returns correct values', () {
      expect(ReminderType.threeDaysBefore.daysBeforeExpiry, 3);
      expect(ReminderType.oneDayBefore.daysBeforeExpiry, 1);
      expect(ReminderType.onExpiryDate.daysBeforeExpiry, 0);
    });

    test('idOffset returns unique values', () {
      final offsets = ReminderType.values.map((e) => e.idOffset).toSet();
      expect(offsets.length, ReminderType.values.length);
      expect(offsets.contains(0), true);
      expect(offsets.contains(1), true);
      expect(offsets.contains(2), true);
    });
  });

  group('Subscription Reminder ID Generation', () {
    test('Unique IDs for Basic Plan', () {
      final basicBase = 10;
      final ids = ReminderType.values.map((type) => basicBase + type.idOffset).toSet();
      
      expect(ids.length, 3);
      expect(ids.contains(10), true);
      expect(ids.contains(11), true);
      expect(ids.contains(12), true);
    });

    test('Unique IDs for Pro Plan', () {
      final proBase = 20;
      final ids = ReminderType.values.map((type) => proBase + type.idOffset).toSet();
      
      expect(ids.length, 3);
      expect(ids.contains(20), true);
      expect(ids.contains(21), true);
      expect(ids.contains(22), true);
    });

    test('IDs do not overlap between plans', () {
      final basicIds = ReminderType.values.map((t) => 10 + t.idOffset).toSet();
      final proIds = ReminderType.values.map((t) => 20 + t.idOffset).toSet();
      
      final intersection = basicIds.intersection(proIds);
      expect(intersection.isEmpty, true);
    });
  });
}
