import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_pro/features/payment/domain/payment_session.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepository(this._firestore);

  Future<void> createSession(PaymentSession session) async {
    await _firestore
        .collection('payment_sessions')
        .doc(session.id)
        .set(session.toFirestore());
  }

  Future<void> updateSessionStatus(String sessionId, PaymentStatus status, {String? transactionId}) async {
    await _firestore.collection('payment_sessions').doc(sessionId).update({
      'status': status.name,
      if (transactionId != null) 'transactionId': transactionId,
    });
  }

  Stream<PaymentSession?> watchSession(String sessionId) {
    return _firestore
        .collection('payment_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return PaymentSession.fromFirestore(snapshot.id, snapshot.data()!);
    });
  }

  Future<PaymentSession?> getSession(String sessionId) async {
    final doc = await _firestore.collection('payment_sessions').doc(sessionId).get();
    if (!doc.exists || doc.data() == null) return null;
    return PaymentSession.fromFirestore(doc.id, doc.data()!);
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(FirebaseFirestore.instance);
});

final paymentSessionStreamProvider = StreamProvider.family<PaymentSession?, String>((ref, sessionId) {
  return ref.watch(paymentRepositoryProvider).watchSession(sessionId);
});
