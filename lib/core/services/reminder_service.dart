import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:io';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'payment_reminders';
  static const String _channelName = 'Payment Reminders';
  static const String _channelDescription = 'Reminders for subscriptions and loan EMIs';

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    _initialized = true;
    debugPrint('✅ Generic ReminderService initialized');
  }

  /// Schedule reminders for a payment (Subscription or Loan)
  /// [id] Unique ID for the item (e.g., Firestore doc ID)
  /// [title] Name of the subscription or loan
  /// [dueDate] The next payment date
  /// [reminderDays] List of days before due date to remind (e.g., [5, 3, 1, 0])
  /// [type] "Subscription" or "Loan" for the message
  Future<void> schedulePaymentReminders({
    required String id,
    required String title,
    required DateTime dueDate,
    required List<int> reminderDays,
    required String type,
  }) async {
    if (!_initialized) await initialize();

    // Cancel existing reminders for this ID first to avoid duplicates
    await cancelReminders(id);

    for (final daysBefore in reminderDays) {
      final scheduledDate = dueDate.subtract(Duration(days: daysBefore));
      
      // Set time to 9:00 AM on the reminder day
      final reminderTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        9, 0, 0,
      );

      if (reminderTime.isBefore(DateTime.now())) continue;

      final notificationId = _generateId(id, daysBefore);
      final message = daysBefore == 0 
          ? "Your $title $type is due today!"
          : "Your $title $type is due in $daysBefore days.";

      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          "$type Reminder",
          message,
          tz.TZDateTime.from(reminderTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: id,
        );
      } catch (e) {
        debugPrint('⚠️ Exact alarm not permitted, falling back to inexact: $e');
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          "$type Reminder",
          message,
          tz.TZDateTime.from(reminderTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: id,
        );
      }
      
      debugPrint('🔔 Scheduled $type reminder for $title: $reminderTime (ID: $notificationId)');
    }
  }

  Future<void> cancelReminders(String id) async {
    if (!_initialized) await initialize();
    
    // Since we generate IDs as hash(id) + daysBefore, we can't easily cancel only specific ones
    // without tracking them. For now, we use a hacky way or just cancel all and reschedule.
    // In a production app, we'd store the notification IDs in Firestore with the model.
    // For this MVP, we'll use a range of common reminder days.
    final commonOffsets = [0, 1, 3, 5, 7, 30];
    for (final offset in commonOffsets) {
      await _notificationsPlugin.cancel(_generateId(id, offset));
    }
  }

  int _generateId(String stringId, int offset) {
    // Generate a consistent int ID from string ID + offset
    return (stringId.hashCode & 0x0FFFFFFF) + offset;
  }
}
