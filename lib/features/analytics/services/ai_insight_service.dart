import '../../expense/domain/expense_model.dart';

class AIInsight {
  final String title;
  final String description;
  final InsightType type;

  AIInsight({required this.title, required this.description, required this.type});
}

enum InsightType { saving, warning, info }

class AIInsightService {
  List<AIInsight> generateInsights(List<ExpenseItem> expenses) {
    if (expenses.isEmpty) return [];

    final insights = <AIInsight>[];
    
    // 1. Category Analysis
    final categoryTotals = <ExpenseCategory, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    // Sort by amount descending
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isNotEmpty) {
      final topCategory = sortedCategories.first;
      insights.add(AIInsight(
        title: 'Top Spending Category',
        description: 'You spent ₹${topCategory.value.toStringAsFixed(2)} on ${topCategory.key.name}. Try setting a budget for this category.',
        type: InsightType.info,
      ));
    }

    // 2. Budget Warnings
    if (categoryTotals[ExpenseCategory.entertainment] != null && 
        categoryTotals[ExpenseCategory.entertainment]! > 5000) {
      insights.add(AIInsight(
        title: 'High Entertainment Spending',
        description: 'Your entertainment spending is quite high this month (₹${categoryTotals[ExpenseCategory.entertainment]!.toStringAsFixed(2)}). Consider cutting back on streaming or outings.',
        type: InsightType.warning,
      ));
    }

    // 3. Saving Opportunities
    if (categoryTotals[ExpenseCategory.food] != null && 
        categoryTotals[ExpenseCategory.food]! > 10000) {
       insights.add(AIInsight(
        title: 'Saving Opportunity',
        description: 'You have spent over ₹10k on Food. Cooking at home more often could save you up to ₹3,000 next month!',
        type: InsightType.saving,
      ));
    }

    // 4. General Trend
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    insights.add(AIInsight(
      title: 'Monthly Summary',
      description: 'Total tracked expenses: ₹${total.toStringAsFixed(2)}. You are tracking ${expenses.length} transactions.',
      type: InsightType.info,
    ));

    return insights;
  }
}
