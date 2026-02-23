import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/finance_insight_engine.dart';
import '../services/balance_forecast_service.dart';
import '../domain/finance_insight.dart';
import '../domain/balance_forecast.dart';
import '../../expense/data/expense_repository.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/providers/wallet_providers.dart';

/// Provider for FinanceInsightEngine
final financeInsightEngineProvider = Provider<FinanceInsightEngine>((ref) {
  return FinanceInsightEngine();
});

/// Provider for BalanceForecastService
final balanceForecastServiceProvider = Provider<BalanceForecastService>((ref) {
  return BalanceForecastService();
});

/// Provider for monthly spending insight (F2)
final monthlySpendingInsightProvider = FutureProvider<FinanceInsight>((ref) async {
  final engine = ref.watch(financeInsightEngineProvider);
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  
  final expenses = await expenseRepo.getAllExpenses();
  
  return await engine.generateMonthlySpendingExplanation(
    expenses: expenses,
  );
});

/// Provider for balance forecast (F4)
final balanceForecastProvider = FutureProvider<BalanceForecast>((ref) async {
  final service = ref.watch(balanceForecastServiceProvider);
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  final walletRepo = await ref.watch(walletRepositoryProvider.future);
  
  final expenses = await expenseRepo.getAllExpenses();
  final currentBalance = await walletRepo.getCurrentBalance();
  
  return await service.calculateMonthEndForecast(
    expenses: expenses,
    currentBalance: currentBalance,
  );
});

/// Cached monthly spending analysis (for performance)
final monthlySpendingAnalysisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  final expenses = await expenseRepo.getAllExpenses();
  
  // Filter to current month
  final now = DateTime.now();
  final thisMonthExpenses = expenses.where((e) {
    return e.date.year == now.year && e.date.month == now.month;
  }).toList();
  
  final total = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  final count = thisMonthExpenses.length;
  
  return {
    'total': total,
    'count': count,
    'expenses': thisMonthExpenses,
  };
});
