import 'package:cloud_firestore/cloud_firestore.dart';

enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  custom,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextDueDate;
  final List<int> reminderDays; // e.g., [5, 3, 1, 0]
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextDueDate,
    required this.reminderDays,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle.name,
      'nextDueDate': nextDueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == data['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      nextDueDate: DateTime.parse(data['nextDueDate']),
      reminderDays: List<int>.from(data['reminderDays'] ?? []),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  SubscriptionModel copyWith({
    String? name,
    double? amount,
    BillingCycle? billingCycle,
    DateTime? nextDueDate,
    List<int>? reminderDays,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
