import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';
import 'package:expense_tracker_pro/features/subscription/providers/subscription_providers.dart';
import 'package:expense_tracker_pro/features/loan/domain/loan_model.dart';
import 'package:expense_tracker_pro/features/loan/data/loan_firestore_repository.dart';

final loanRepositoryProvider = Provider<LoanFirestoreRepository?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) return null;
  return LoanFirestoreRepository(firestore, user.uid);
});

final loansStreamProvider = StreamProvider<List<LoanModel>>((ref) {
  final repo = ref.watch(loanRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchLoans();
});

final activeLoansProvider = Provider<List<LoanModel>>((ref) {
  final loans = ref.watch(loansStreamProvider).value ?? [];
  return loans.where((l) => l.status == LoanStatus.active).toList()
    ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
});
