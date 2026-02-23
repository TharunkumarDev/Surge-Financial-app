import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expense/domain/expense_model.dart';
import '../../features/wallet/domain/wallet_model.dart';
import '../../features/subscription/providers/subscription_providers.dart';
import '../../features/auth/providers/auth_providers.dart';

class CloudSyncRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  CloudSyncRepository(this._firestore, this.userId);

  // --- Expenses ---

  CollectionReference<Map<String, dynamic>> get _expenseRef =>
      _firestore.collection('users').doc(userId).collection('expenses');

  Future<void> pushExpenses(List<ExpenseItem> items) async {
    final batch = _firestore.batch();
    for (var item in items) {
      batch.set(_expenseRef.doc(item.id.toString()), item.toMap());
    }
    await batch.commit();
  }

  Future<List<ExpenseItem>> fetchExpenseDeltas(DateTime lastSync) async {
    final snapshot = await _expenseRef
        .where('updatedAt', isGreaterThan: lastSync.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => ExpenseItem.fromMap(doc.data(), isarId: int.tryParse(doc.id))).toList();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchExpensesPaginated({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _expenseRef.orderBy('updatedAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return await query.get();
  }

  // --- Wallet ---

  DocumentReference<Map<String, dynamic>> get _walletRef =>
      _firestore.collection('users').doc(userId).collection('wallet').doc('main');

  Future<void> pushWallet(Wallet wallet) async {
    await _walletRef.set(wallet.toMap());
  }

  Future<Wallet?> fetchWallet() async {
    final doc = await _walletRef.get();
    if (!doc.exists) return null;
    return Wallet.fromMap(doc.data()!);
  }
}

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return null;
  return CloudSyncRepository(firestore, user.uid);
});
