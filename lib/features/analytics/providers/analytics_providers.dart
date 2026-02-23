import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expense/data/expense_repository.dart';
import '../../expense/domain/expense_model.dart';
import '../services/ai_insight_service.dart';

// Moved from AnalyticsScreen to be shared
final expenseListProvider = StreamProvider<List<ExpenseItem>>((ref) async* {
  final repo = await ref.watch(expenseRepositoryProvider.future);
  yield* repo.watchExpenses();
});

final aiInsightsProvider = FutureProvider<List<AIInsight>>((ref) async {
  final expenses = ref.watch(expenseListProvider).value ?? [];
  
  if (expenses.isEmpty) {
    return [];
  }

  // Calculate totals
  final currentMonth = DateTime.now().month;
  final thisMonthExpenses = expenses.where((e) => e.date.month == currentMonth).toList();
  final totalSpent = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  
  // Basic rule-based AI insights (mock implementation for now)
  final insights = <AIInsight>[];
  
  if (totalSpent > 1000) {
    insights.add(AIInsight(
      title: "High Spending Alert",
      description: "You've spent \$${totalSpent.toStringAsFixed(0)} this month. Consider reviewing your budget.",
      type: InsightType.warning,
    ));
  } else if (totalSpent < 500 && totalSpent > 0) {
    insights.add(AIInsight(
      title: "Great Saving!",
      description: "You're keeping your expenses low this month. Good job!",
      type: InsightType.saving,
    ));
  }
  
  return insights;
});
