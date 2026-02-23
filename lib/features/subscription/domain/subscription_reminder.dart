import 'package:freezed_annotation/freezed_annotation.dart';
import 'subscription_plan.dart';

part 'subscription_reminder.freezed.dart';

@freezed
class SubscriptionReminder with _$SubscriptionReminder {
  const factory SubscriptionReminder({
    required String id,
    required SubscriptionTier tier,
    required DateTime planStartDate,
    required DateTime planExpiryDate,
    DateTime? lastReminderSent,
    required List<DateTime> scheduledReminders,
  }) = _SubscriptionReminder;

  const SubscriptionReminder._();

  // Helper to check if plan is still active
  bool get isActive => planExpiryDate.isAfter(DateTime.now());

  // Helper to get days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    if (planExpiryDate.isBefore(now)) return 0;
    return planExpiryDate.difference(now).inDays;
  }
}
