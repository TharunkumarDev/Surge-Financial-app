import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_reminder.dart';
import 'reminder_notification_service.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final ReminderNotificationService _reminderService;

  SubscriptionRepository(this._firestore, this._reminderService);

  // Get user subscription from Firestore
  Future<SubscriptionPlan> getUserSubscription(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists || doc.data()?['subscription'] == null) {
        // Create default free subscription
        final freePlan = SubscriptionPlan.free();
        await _createUserSubscription(userId, freePlan);
        return freePlan;
      }
      
      final subscriptionData = doc.data()!['subscription'] as Map<String, dynamic>;
      final plan = SubscriptionPlan.fromFirestore(subscriptionData);
      
      // Check if monthly reset is needed
      if (_needsMonthlyReset(plan.lastResetDate)) {
        return await _resetMonthlyCounter(userId, plan);
      }
      
      return plan;
    } catch (e) {
      // Return free plan on error
      return SubscriptionPlan.free();
    }
  }

  // Watch user subscription changes
  Stream<SubscriptionPlan> watchUserSubscription(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data()?['subscription'] == null) {
        return SubscriptionPlan.free();
      }
      
      final subscriptionData = doc.data()!['subscription'] as Map<String, dynamic>;
      return SubscriptionPlan.fromFirestore(subscriptionData);
    }).handleError((error) {
      // Gracefully handle permission errors or other stream failures
      debugPrint('Error watching subscription: $error');
      return SubscriptionPlan.free();
    });
  }

  // Create user subscription
  Future<void> _createUserSubscription(String userId, SubscriptionPlan plan) async {
    await _firestore.collection('users').doc(userId).set({
      'subscription': plan.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update subscription plan with reminder scheduling
  Future<void> updateSubscription(
    String userId,
    SubscriptionTier newTier, {
    SubscriptionTier? oldTier,
  }) async {
    final now = DateTime.now();
    final planStartDate = now;
    final planExpiryDate = now.add(const Duration(days: 30));
    
    final newPlan = SubscriptionPlan(
      tier: newTier,
      purchasedAt: now,
      expiresAt: null, // Lifetime subscription
      billCapturesThisMonth: 0,
      lastResetDate: now,
    );
    
    // Update Firestore with plan dates
    await _firestore.collection('users').doc(userId).update({
      'subscription': newPlan.toFirestore(),
      'planStartDate': planStartDate.toIso8601String(),
      'planExpiryDate': planExpiryDate.toIso8601String(),
      'lastReminderSent': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Handle reminder scheduling
    await _handleReminderScheduling(
      userId: userId,
      oldTier: oldTier,
      newTier: newTier,
      planStartDate: planStartDate,
      planExpiryDate: planExpiryDate,
    );
  }

  // Increment bill capture count
  Future<void> incrementBillCapture(String userId) async {
    final plan = await getUserSubscription(userId);
    final updatedPlan = plan.copyWith(
      billCapturesThisMonth: plan.billCapturesThisMonth + 1,
    );
    
    await _firestore.collection('users').doc(userId).update({
      'subscription': updatedPlan.toFirestore(),
    });
  }

  // Reset monthly counter
  Future<SubscriptionPlan> _resetMonthlyCounter(String userId, SubscriptionPlan plan) async {
    final resetPlan = plan.copyWith(
      billCapturesThisMonth: 0,
      lastResetDate: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(userId).update({
      'subscription': resetPlan.toFirestore(),
    });
    
    return resetPlan;
  }

  // Check if monthly reset is needed
  bool _needsMonthlyReset(DateTime lastResetDate) {
    final now = DateTime.now();
    return now.year > lastResetDate.year || now.month > lastResetDate.month;
  }

  // Check if user can capture bill
  Future<bool> canCaptureBill(String userId) async {
    final plan = await getUserSubscription(userId);
    
    // Free plan cannot capture
    if (plan.tier == SubscriptionTier.free) {
      return false;
    }
    
    // Pro plan has unlimited captures
    if (plan.tier == SubscriptionTier.pro) {
      return true;
    }
    
    // Basic plan has monthly limit
    const basicLimit = 10;
    return plan.billCapturesThisMonth < basicLimit;
  }

  // Handle reminder scheduling on plan change
  Future<void> _handleReminderScheduling({
    required String userId,
    SubscriptionTier? oldTier,
    required SubscriptionTier newTier,
    required DateTime planStartDate,
    required DateTime planExpiryDate,
  }) async {
    // If downgrading to Free, cancel all reminders
    if (newTier == SubscriptionTier.free) {
      if (oldTier != null && oldTier != SubscriptionTier.free) {
        await _reminderService.cancelReminders(oldTier);
        debugPrint('🗑️ Cancelled reminders (downgraded to Free)');
      }
      return;
    }

    // Create reminder model
    final reminder = SubscriptionReminder(
      id: userId,
      tier: newTier,
      planStartDate: planStartDate,
      planExpiryDate: planExpiryDate,
      scheduledReminders: [
        planExpiryDate.subtract(const Duration(days: 3)),
        planExpiryDate.subtract(const Duration(days: 1)),
        planExpiryDate,
      ],
    );

    // If upgrading/downgrading between Basic and Pro
    if (oldTier != null && oldTier != newTier && oldTier != SubscriptionTier.free) {
      await _reminderService.rescheduleReminders(
        oldTier: oldTier,
        newReminder: reminder,
      );
    } else {
      // New subscription
      await _reminderService.scheduleReminders(reminder);
    }
  }
}
