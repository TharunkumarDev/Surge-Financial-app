import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/subscription_model.dart';

class SubscriptionFirestoreRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  SubscriptionFirestoreRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _subscriptionsRef =>
      _firestore.collection('users').doc(_userId).collection('subscriptions');

  Stream<List<SubscriptionModel>> watchSubscriptions() {
    return _subscriptionsRef
        .orderBy('nextDueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc))
            .toList())
        .handleError((error) {
      debugPrint('Error watching subscriptions: $error');
      return <SubscriptionModel>[]; // Return empty list on permission error
    });
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    await _subscriptionsRef.doc(subscription.id).set(subscription.toFirestore());
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await _subscriptionsRef.doc(subscription.id).update(subscription.toFirestore());
  }

  Future<void> deleteSubscription(String id) async {
    await _subscriptionsRef.doc(id).delete();
  }

  Future<void> markAsPaid(SubscriptionModel subscription) async {
    // Calculate next due date
    DateTime nextDate = subscription.nextDueDate;
    switch (subscription.billingCycle) {
      case BillingCycle.monthly:
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        break;
      case BillingCycle.quarterly:
        nextDate = DateTime(nextDate.year, nextDate.month + 3, nextDate.day);
        break;
      case BillingCycle.yearly:
        nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
        break;
      case BillingCycle.custom:
        // Custom logic or keep same if not auto-calculable
        break;
    }

    final updatedSubscription = subscription.copyWith(
      nextDueDate: nextDate,
      updatedAt: DateTime.now(),
    );

    await updateSubscription(updatedSubscription);
  }
}
