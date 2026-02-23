import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/subscription/providers/subscription_providers.dart';
import '../../features/auth/providers/auth_providers.dart';

class FirestoreListenerManager {
  final FirebaseFirestore _firestore;
  final String userId;
  
  StreamSubscription? _expenseSubscription;
  StreamSubscription? _walletSubscription;
  StreamSubscription? _loanSubscription;
  StreamSubscription? _subscriptionSubscription;

  final _expenseController = StreamController<DocumentChange<Map<String, dynamic>>>.broadcast();
  final _walletController = StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
  final _loanController = StreamController<DocumentChange<Map<String, dynamic>>>.broadcast();
  final _subscriptionController = StreamController<DocumentChange<Map<String, dynamic>>>.broadcast();

  FirestoreListenerManager(this._firestore, this.userId);

  Stream<DocumentChange<Map<String, dynamic>>> get expenseChanges => _expenseController.stream;
  Stream<DocumentSnapshot<Map<String, dynamic>>> get walletChanges => _walletController.stream;
  Stream<DocumentChange<Map<String, dynamic>>> get loanChanges => _loanController.stream;
  Stream<DocumentChange<Map<String, dynamic>>> get subscriptionChanges => _subscriptionController.stream;

  void attachListeners() {
    _detachListeners(); // Safety

    // Expenses Listener
    _expenseSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        _expenseController.add(change);
      }
    });

    // Wallet Listener
    _walletSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('wallet')
        .doc('main')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _walletController.add(snapshot);
      }
    });

    // Loans Listener
    _loanSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('loans')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        _loanController.add(change);
      }
    }, onError: (error) => debugPrint('Loan listener error: $error'));

    // Subscriptions Listener
    _subscriptionSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        _subscriptionController.add(change);
      }
    }, onError: (error) => debugPrint('Subscription listener error: $error'));
  }

  void _detachListeners() {
    _expenseSubscription?.cancel();
    _walletSubscription?.cancel();
    _loanSubscription?.cancel();
    _subscriptionSubscription?.cancel();
  }

  void dispose() {
    _detachListeners();
    _expenseController.close();
    _walletController.close();
    _loanController.close();
    _subscriptionController.close();
  }
}

final firestoreListenerManagerProvider = Provider<FirestoreListenerManager?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return null;
  
  final manager = FirestoreListenerManager(firestore, user.uid);
  ref.onDispose(() => manager.dispose());
  return manager;
});
