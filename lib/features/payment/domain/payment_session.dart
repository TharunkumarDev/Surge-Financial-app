import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_plan.dart';

enum PaymentStatus {
  pending,
  success,
  failed,
  expired,
}

class PaymentSession {
  final String id;
  final String userId;
  final SubscriptionTier planId;
  final int amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? transactionId;
  final String? upiIntentUrl;

  PaymentSession({
    required this.id,
    required this.userId,
    required this.planId,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.transactionId,
    this.upiIntentUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId.name,
      'amount': amount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'transactionId': transactionId,
      'upiIntentUrl': upiIntentUrl,
    };
  }

  factory PaymentSession.fromFirestore(String id, Map<String, dynamic> data) {
    return PaymentSession(
      id: id,
      userId: data['userId'] as String,
      planId: SubscriptionTier.fromString(data['planId'] as String),
      amount: data['amount'] as int,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String),
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      transactionId: data['transactionId'] as String?,
      upiIntentUrl: data['upiIntentUrl'] as String?,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  PaymentSession copyWith({
    PaymentStatus? status,
    String? transactionId,
    String? upiIntentUrl,
  }) {
    return PaymentSession(
      id: id,
      userId: userId,
      planId: planId,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      transactionId: transactionId ?? this.transactionId,
      upiIntentUrl: upiIntentUrl ?? this.upiIntentUrl,
    );
  }
}
