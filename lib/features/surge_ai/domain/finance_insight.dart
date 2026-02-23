/// Domain model for AI-generated financial insights
class FinanceInsight {
  final String title;
  final String explanation;
  final Map<String, double> categoryBreakdown; // Category name -> percentage
  final WeekendAnalysis? weekendAnalysis;
  final List<CategorySummary> topExpenses;
  final DateTime generatedAt;
  final InsightType type;
  
  FinanceInsight({
    required this.title,
    required this.explanation,
    required this.categoryBreakdown,
    this.weekendAnalysis,
    required this.topExpenses,
    required this.generatedAt,
    this.type = InsightType.spending,
  });
  
  factory FinanceInsight.empty() {
    return FinanceInsight(
      title: 'No Data Available',
      explanation: 'Start tracking expenses to see spending insights.',
      categoryBreakdown: {},
      topExpenses: [],
      generatedAt: DateTime.now(),
    );
  }
}

/// Weekend vs weekday spending comparison
class WeekendAnalysis {
  final double weekendTotal;
  final double weekdayTotal;
  final double weekendPercentage;
  final double ratio; // weekend / weekday
  
  WeekendAnalysis({
    required this.weekendTotal,
    required this.weekdayTotal,
    required this.weekendPercentage,
    required this.ratio,
  });
  
  bool get isWeekendHeavy => ratio > 1.5;
  
  String get summary {
    if (ratio > 2.0) {
      return 'Weekend spending is ${ratio.toStringAsFixed(1)}x your weekday average';
    } else if (ratio > 1.5) {
      return 'You spend ${(ratio * 100 - 100).toStringAsFixed(0)}% more on weekends';
    } else if (ratio < 0.7) {
      return 'Your weekday spending is higher than weekends';
    } else {
      return 'Weekend and weekday spending are balanced';
    }
  }
}

/// Category spending summary
class CategorySummary {
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;
  
  CategorySummary({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

/// Type of insight
enum InsightType {
  spending,
  forecast,
  personality,
  risk,
  bill,
}
