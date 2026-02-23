import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanStatus {
  active,
  completed,
}

class LoanModel {
  final String id;
  final String userId;
  final String name; // Name of person or bank
  final double totalAmount;
  final double remainingAmount;
  final double emiAmount;
  final DateTime nextDueDate;
  final List<int> reminderDays;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    required this.emiAmount,
    required this.nextDueDate,
    required this.reminderDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'emiAmount': emiAmount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (data['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      emiAmount: (data['emiAmount'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: DateTime.parse(data['nextDueDate']),
      reminderDays: List<int>.from(data['reminderDays'] ?? []),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => LoanStatus.active,
      ),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  LoanModel copyWith({
    String? name,
    double? totalAmount,
    double? remainingAmount,
    double? emiAmount,
    DateTime? nextDueDate,
    List<int>? reminderDays,
    LoanStatus? status,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      emiAmount: emiAmount ?? this.emiAmount,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
