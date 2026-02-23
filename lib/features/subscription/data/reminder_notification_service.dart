import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../domain/subscription_plan.dart';
import '../domain/reminder_type.dart';
import '../domain/subscription_reminder.dart';

class ReminderNotificationService {
  static final ReminderNotificationService _instance = ReminderNotificationService._internal();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channel details
  static const String _channelId = 'subscription_reminders';
  static const String _channelName = 'Subscription Reminders';
  static const String _channelDescription = 'Monthly subscription renewal reminders';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    _initialized = true;
    debugPrint('✅ ReminderNotificationService initialized');
  }

  /// Request notification permissions on iOS
  Future<void> _requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Can navigate to pricing/subscription screen if needed
  }

  /// Schedule all reminders for a subscription
  Future<void> scheduleReminders(SubscriptionReminder reminder) async {
    if (!_initialized) await initialize();

    // Only schedule for Basic and Pro plans
    if (reminder.tier == SubscriptionTier.free) {
      debugPrint('⚠️ Free plan - no reminders scheduled');
      return;
    }

    debugPrint('📅 Scheduling reminders for ${reminder.tier.displayName} plan');
    debugPrint('   Start: ${reminder.planStartDate}');
    debugPrint('   Expiry: ${reminder.planExpiryDate}');

    // Schedule reminder for each type
    for (final type in ReminderType.values) {
      await _scheduleReminder(reminder, type);
    }

    debugPrint('✅ Scheduled 3 reminders for ${reminder.tier.displayName} plan');
  }

  /// Schedule a single reminder
  Future<void> _scheduleReminder(SubscriptionReminder reminder, ReminderType type) async {
    final scheduledDate = reminder.planExpiryDate.subtract(
      Duration(days: type.daysBeforeExpiry),
    );

    // Don't schedule if the date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Skipping ${type.displayName} - date in past: $scheduledDate');
      return;
    }

    final notificationId = _generateNotificationId(reminder.tier, type);
    final title = _getNotificationTitle(reminder.tier, type);
    final body = _getNotificationBody(reminder.tier, type, reminder.planExpiryDate);

    // Convert to timezone-aware date
    final scheduledTZ = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${reminder.tier.name}_${type.name}',
    );

    debugPrint('   ✓ Scheduled: ${type.displayName} on $scheduledDate (ID: $notificationId)');
  }

  /// Cancel all reminders for a specific plan
  Future<void> cancelReminders(SubscriptionTier tier) async {
    if (!_initialized) await initialize();

    debugPrint('🗑️ Cancelling reminders for ${tier.displayName} plan');

    for (final type in ReminderType.values) {
      final notificationId = _generateNotificationId(tier, type);
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('   ✓ Cancelled: ${type.displayName} (ID: $notificationId)');
    }
  }

  /// Reschedule reminders (cancel old + schedule new)
  Future<void> rescheduleReminders({
    required SubscriptionTier oldTier,
    required SubscriptionReminder newReminder,
  }) async {
    debugPrint('🔄 Rescheduling: ${oldTier.displayName} → ${newReminder.tier.displayName}');
    
    // Cancel old reminders
    await cancelReminders(oldTier);

    // Schedule new reminders
    await scheduleReminders(newReminder);
  }

  /// Generate unique notification ID
  int _generateNotificationId(SubscriptionTier tier, ReminderType type) {
    // Base ID: tier (1=basic, 2=pro) * 10 + reminder type offset
    final tierBase = tier == SubscriptionTier.basic ? 10 : 20;
    return tierBase + type.idOffset;
  }

  /// Get notification title
  String _getNotificationTitle(SubscriptionTier tier, ReminderType type) {
    return switch (type) {
      ReminderType.threeDaysBefore => 'Your ${tier.displayName} Plan is Expiring Soon',
      ReminderType.oneDayBefore => '${tier.displayName} Plan Expires Tomorrow',
      ReminderType.onExpiryDate => 'Your ${tier.displayName} Plan Expired Today',
    };
  }

  /// Get notification body
  String _getNotificationBody(SubscriptionTier tier, ReminderType type, DateTime expiryDate) {
    final daysLeft = type.daysBeforeExpiry;
    
    if (daysLeft == 0) {
      return 'Your ${tier.displayName} subscription has expired. Renew now to continue enjoying premium features!';
    } else if (daysLeft == 1) {
      return 'Your ${tier.displayName} subscription expires tomorrow. Renew to keep access to all features.';
    } else {
      return 'Your ${tier.displayName} subscription expires in $daysLeft days. Tap to renew and continue using premium features.';
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Cancel all notifications (for cleanup/testing)
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ Cancelled all notifications');
  }
}
