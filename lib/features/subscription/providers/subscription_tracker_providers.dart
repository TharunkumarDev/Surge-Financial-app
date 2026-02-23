import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';
import 'package:expense_tracker_pro/features/subscription/providers/subscription_providers.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_model.dart';
import 'package:expense_tracker_pro/features/subscription/data/subscription_firestore_repository.dart';

final subscriptionTrackerRepositoryProvider = Provider<SubscriptionFirestoreRepository?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) return null;
  return SubscriptionFirestoreRepository(firestore, user.uid);
});

final subscriptionsStreamProvider = StreamProvider<List<SubscriptionModel>>((ref) {
  final repo = ref.watch(subscriptionTrackerRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchSubscriptions();
});

final upcomingSubscriptionsProvider = Provider<List<SubscriptionModel>>((ref) {
  final subscriptions = ref.watch(subscriptionsStreamProvider).value ?? [];
  final now = DateTime.now();
  
  return subscriptions
      .where((s) => s.nextDueDate.isAfter(now) || s.nextDueDate.day == now.day && s.nextDueDate.month == now.month)
      .toList()
    ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
});
