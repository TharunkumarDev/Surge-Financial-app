import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';
import '../domain/expense_model.dart';

final recentExpensesProvider = StreamProvider<List<ExpenseItem>>((ref) async* {
  final repo = await ref.watch(expenseRepositoryProvider.future);
  await for (final items in repo.watchExpenses()) {
    yield items.take(10).toList();
  }
});

final allExpensesProvider = StreamProvider<List<ExpenseItem>>((ref) async* {
  final repo = await ref.watch(expenseRepositoryProvider.future);
  await for (final items in repo.watchExpenses()) {
    yield items;
  }
});

// Today's spending
final todaySpendingProvider = Provider<AsyncValue<double>>((ref) {
  final expensesAsync = ref.watch(allExpensesProvider);
  
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final todayExpenses = expenses.where((expense) {
        return expense.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
               expense.date.isBefore(tomorrow);
      });
      
      final total = todayExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      return AsyncValue.data(total);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// This week's spending (Monday to Sunday)
final thisWeekSpendingProvider = Provider<AsyncValue<double>>((ref) {
  final expensesAsync = ref.watch(allExpensesProvider);
  
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final weekday = now.weekday;
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      
      final weekExpenses = expenses.where((expense) {
        return expense.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
               expense.date.isBefore(endOfWeek);
      });
      
      final total = weekExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      return AsyncValue.data(total);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// This month's spending
final thisMonthSpendingProvider = Provider<AsyncValue<double>>((ref) {
  final expensesAsync = ref.watch(allExpensesProvider);
  
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);
      
      final monthExpenses = expenses.where((expense) {
        return expense.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
               expense.date.isBefore(endOfMonth);
      });
      
      final total = monthExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      return AsyncValue.data(total);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
