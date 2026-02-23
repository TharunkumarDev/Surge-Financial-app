import '../domain/finance_insight.dart';
import '../../expense/domain/expense_model.dart';

/// F2: Finance Insight Engine
/// Generates "Where Did My Money Go?" explanations with privacy-safe aggregated data
class FinanceInsightEngine {
  /// Generate monthly spending explanation
  Future<FinanceInsight> generateMonthlySpendingExplanation({
    required List<ExpenseItem> expenses,
  }) async {
    if (expenses.isEmpty) {
      return FinanceInsight.empty();
    }
    
    // Filter to current month
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
    
    if (thisMonthExpenses.isEmpty) {
      return FinanceInsight.empty();
    }
    
    // Analyze category distribution
    final categoryBreakdown = analyzeCategoryDistribution(thisMonthExpenses);
    
    // Compare weekend vs weekday
    final weekendAnalysis = compareWeekendVsWeekday(thisMonthExpenses);
    
    // Identify top expenses
    final topExpenses = identifyTopExpenses(thisMonthExpenses);
    
    // Generate natural language explanation
    final explanation = _generateExplanation(
      categoryBreakdown: categoryBreakdown,
      weekendAnalysis: weekendAnalysis,
      topExpenses: topExpenses,
      totalSpent: thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount),
    );
    
    return FinanceInsight(
      title: 'Monthly Spending Breakdown',
      explanation: explanation,
      categoryBreakdown: categoryBreakdown,
      weekendAnalysis: weekendAnalysis,
      topExpenses: topExpenses,
      generatedAt: DateTime.now(),
      type: InsightType.spending,
    );
  }
  
  /// Analyze spending by category (privacy-safe: percentages only)
  Map<String, double> analyzeCategoryDistribution(List<ExpenseItem> expenses) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    if (total == 0) return {};
    
    // Group by category
    final categoryTotals = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    // Convert to percentages
    final percentages = <String, double>{};
    categoryTotals.forEach((category, amount) {
      final percentage = (amount / total) * 100;
      percentages[category.name] = percentage;
    });
    
    return percentages;
  }
  
  /// Compare weekend vs weekday spending
  WeekendAnalysis compareWeekendVsWeekday(List<ExpenseItem> expenses) {
    double weekendTotal = 0;
    double weekdayTotal = 0;
    
    for (final expense in expenses) {
      final isWeekend = expense.date.weekday == DateTime.saturday || 
                       expense.date.weekday == DateTime.sunday;
      if (isWeekend) {
        weekendTotal += expense.amount.toDouble();
      } else {
        weekdayTotal += expense.amount.toDouble();
      }
    }
    
    final total = weekendTotal + weekdayTotal;
    final double weekendPercentage = total > 0 ? (weekendTotal / total) * 100 : 0.0;
    final double ratio = weekdayTotal > 0 ? weekendTotal / weekdayTotal : 0.0;
    
    return WeekendAnalysis(
      weekendTotal: weekendTotal,
      weekdayTotal: weekdayTotal,
      weekendPercentage: weekendPercentage,
      ratio: ratio,
    );
  }
  
  /// Identify top expense categories
  List<CategorySummary> identifyTopExpenses(List<ExpenseItem> expenses) {
    // Group by category
    final categoryData = <ExpenseCategory, _CategoryData>{};
    for (final expense in expenses) {
      if (!categoryData.containsKey(expense.category)) {
        categoryData[expense.category] = _CategoryData();
      }
      categoryData[expense.category]!.amount += expense.amount;
      categoryData[expense.category]!.count += 1;
    }
    
    // Convert to summaries and sort by amount
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final summaries = categoryData.entries.map((entry) {
      return CategorySummary(
        categoryName: entry.key.name,
        amount: entry.value.amount,
        percentage: total > 0 ? (entry.value.amount / total) * 100 : 0,
        transactionCount: entry.value.count,
      );
    }).toList();
    
    summaries.sort((a, b) => b.amount.compareTo(a.amount));
    
    return summaries.take(5).toList(); // Top 5 categories
  }
  
  /// Generate natural language explanation (AI-like, but deterministic)
  String _generateExplanation({
    required Map<String, double> categoryBreakdown,
    required WeekendAnalysis? weekendAnalysis,
    required List<CategorySummary> topExpenses,
    required double totalSpent,
  }) {
    final parts = <String>[];
    
    // Opening statement
    parts.add('This month, you spent ₹${totalSpent.toStringAsFixed(0)} across ${topExpenses.length} categories.');
    
    // Top categories
    if (topExpenses.isNotEmpty) {
      final top1 = topExpenses[0];
      final top2 = topExpenses.length > 1 ? topExpenses[1] : null;
      
      if (top2 != null) {
        parts.add(
          'Most of your spending went to ${_formatCategoryName(top1.categoryName)} '
          '(${top1.percentage.toStringAsFixed(0)}%) and '
          '${_formatCategoryName(top2.categoryName)} '
          '(${top2.percentage.toStringAsFixed(0)}%).'
        );
      } else {
        parts.add(
          'Most of your spending went to ${_formatCategoryName(top1.categoryName)} '
          '(${top1.percentage.toStringAsFixed(0)}%).'
        );
      }
    }
    
    // Weekend analysis
    if (weekendAnalysis != null && weekendAnalysis.isWeekendHeavy) {
      parts.add(weekendAnalysis.summary + '.');
    }
    
    // Spending tip
    if (topExpenses.isNotEmpty && topExpenses[0].percentage > 40) {
      parts.add(
        'Consider reviewing your ${_formatCategoryName(topExpenses[0].categoryName)} '
        'expenses to find potential savings.'
      );
    }
    
    return parts.join(' ');
  }
  
  String _formatCategoryName(String category) {
    // Convert enum name to readable format
    switch (category.toLowerCase()) {
      case 'food':
        return 'food';
      case 'transport':
        return 'transport';
      case 'shopping':
        return 'shopping';
      case 'entertainment':
        return 'entertainment';
      case 'bills':
        return 'bills & utilities';
      case 'health':
        return 'health';
      case 'education':
        return 'education';
      case 'other':
        return 'other expenses';
      default:
        return category;
    }
  }
}

/// Helper class for category aggregation
class _CategoryData {
  double amount = 0;
  int count = 0;
}
