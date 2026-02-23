import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/subscription_repository.dart';
import '../data/reminder_notification_service.dart';
import '../domain/subscription_plan.dart';
import '../services/entitlement_service.dart';
// lib/core/services/sync_service.dart removed
import '../../../core/utils/isar_provider.dart';

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Reminder notification service provider
final reminderServiceProvider = Provider<ReminderNotificationService>((ref) {
  return ReminderNotificationService();
});

// Subscription repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final reminderService = ref.watch(reminderServiceProvider);
  return SubscriptionRepository(firestore, reminderService);
});

// Entitlement service provider
final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  return EntitlementService();
});

// Current user subscription provider
final currentSubscriptionProvider = StreamProvider<SubscriptionPlan?>((ref) {
  final authState = ref.watch(authStateProvider);
  final repo = ref.watch(subscriptionRepositoryProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      } else {
        return repo.watchUserSubscription(user.uid);
      }
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Current subscription tier provider (convenience)
final currentSubscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  // Admin Override Logic
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user?.email == 'tharun98414@gmail.com') {
    return SubscriptionTier.pro;
  }

  final subscription = ref.watch(currentSubscriptionProvider).value;
  return subscription?.tier ?? SubscriptionTier.free;
});

// Sync logic moved to lib/core/services/sync_coordinator.dart
