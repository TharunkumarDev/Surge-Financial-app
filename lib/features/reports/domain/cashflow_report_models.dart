class MonthlyCashflow {
  final double totalSent;
  final double totalReceived;
  final double netCashflow;
  final double sentChangePercentage; // MoM change
  final double receivedChangePercentage; // MoM change

  const MonthlyCashflow({
    required this.totalSent,
    required this.totalReceived,
    required this.netCashflow,
    required this.sentChangePercentage,
    required this.receivedChangePercentage,
  });
}

class CategoryCashflow {
  final String categoryName;
  final double totalAmount;
  final double percentageOfTotal;
  final bool isCredit; // true for income source, false for expense category

  const CategoryCashflow({
    required this.categoryName,
    required this.totalAmount,
    required this.percentageOfTotal,
    required this.isCredit,
  });
}

class UpiContactStats {
  final String name;
  final double totalAmount;
  final int transactionCount;
  final bool isReceiver; // true if we sent money TO them (receiver)

  const UpiContactStats({
    required this.name,
    required this.totalAmount,
    required this.transactionCount,
    required this.isReceiver,
  });
}

class DailyCashflow {
  final DateTime date;
  final double sent;
  final double received;

  const DailyCashflow({
    required this.date,
    required this.sent,
    required this.received,
  });
  
  double get net => received - sent;
}

class CashflowTrendPoint {
  final DateTime date;
  final double value;

  const CashflowTrendPoint({
    required this.date,
    required this.value,
  });
}

class AdvancedMetrics {
  final double averageDailySpend;
  final double averageDailyIncome;
  final double savingsRate; // (Credit - Debit) / Credit * 100
  final double expenseVolatilityScore; // Standard deviation of daily spend
  final double incomeConsistencyScore; // Standard deviation of daily income (lower is better)

  const AdvancedMetrics({
    required this.averageDailySpend,
    required this.averageDailyIncome,
    required this.savingsRate,
    required this.expenseVolatilityScore,
    required this.incomeConsistencyScore,
  });
}

class FullCashflowReport {
  final DateTime startDate;
  final DateTime endDate;
  final MonthlyCashflow monthlySummary;
  final List<CategoryCashflow> expenseCategories;
  final List<CategoryCashflow> incomeSources;
  final List<UpiContactStats> topReceivers; // Money sent TO
  final List<UpiContactStats> topSenders; // Money received FROM
  final List<DailyCashflow> dailyTrend;
  final AdvancedMetrics advancedMetrics;

  const FullCashflowReport({
    required this.startDate,
    required this.endDate,
    required this.monthlySummary,
    required this.expenseCategories,
    required this.incomeSources,
    required this.topReceivers,
    required this.topSenders,
    required this.dailyTrend,
    required this.advancedMetrics,
  });
}
