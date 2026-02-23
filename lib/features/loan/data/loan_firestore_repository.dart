import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/loan_model.dart';
import '../../expense/domain/expense_model.dart';

class LoanFirestoreRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  LoanFirestoreRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _loansRef =>
      _firestore.collection('users').doc(_userId).collection('loans');

  Stream<List<LoanModel>> watchLoans() {
    return _loansRef
        .orderBy('nextDueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromFirestore(doc))
            .toList())
        .handleError((error) {
      debugPrint('Error watching loans: $error');
      return <LoanModel>[]; // Return empty list on permission error
    });
  }

  Future<void> addLoan(LoanModel loan) async {
    await _loansRef.doc(loan.id).set(loan.toFirestore());
  }

  Future<void> updateLoan(LoanModel loan) async {
    await _loansRef.doc(loan.id).update(loan.toFirestore());
  }

  Future<void> deleteLoan(String id) async {
    await _loansRef.doc(id).delete();
  }

  Future<void> recordPayment(LoanModel loan, double amount) async {
    double newRemaining = loan.remainingAmount - amount;
    LoanStatus newStatus = loan.status;

    if (newRemaining <= 0) {
      newRemaining = 0;
      newStatus = LoanStatus.completed;
    }

    // Calculate next due date (assume monthly EMI)
    DateTime nextDate = DateTime(
      loan.nextDueDate.year,
      loan.nextDueDate.month + 1,
      loan.nextDueDate.day,
    );

    final updatedLoan = loan.copyWith(
      remainingAmount: newRemaining,
      status: newStatus,
      nextDueDate: nextDate,
      updatedAt: DateTime.now(),
    );

    await updateLoan(updatedLoan);
  }
}
