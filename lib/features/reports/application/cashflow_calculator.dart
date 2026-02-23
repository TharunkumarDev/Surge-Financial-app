import '../domain/cashflow_report_models.dart';
import '../../expense/domain/expense_model.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
import 'dart:math';

class CashflowCalculator {
  
  static FullCashflowReport calculateReport({
    required List<ExpenseItem> expenses,
    required List<AutoTransaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 1. Separate Transactions
    // Credits: From AutoTransactions (type=credit)
    // Debits: From ExpenseItems mainly. AutoTransaction(debit) is supplementary (upi report).
    
    final credits = transactions.where((t) => t.type == TransactionType.credit).toList();
    final debitTransactions = transactions.where((t) => t.type == TransactionType.debit).toList();
    
    // 2. Metrics Calculation
    double totalSent = 0;
    double totalReceived = 0;
    
    for (var e in expenses) totalSent += e.amount;
    for (var c in credits) totalReceived += (c.amount ?? 0);

    // 3. Monthly Analysis (Current Month vs Previous)
    // This assumes the inputs 'expenses' and 'transactions' cover the requested range + buffer for trends?
    // If exact range provided, we can only calc summary for that range.
    // Let's calculate for the *entire input set* but the "Monthly Summary" focuses on the *current month* relative to EndDate?
    // The prompt asks for "Monthly Cashflow Report" which often implies a list of months or "Current Month" stats.
    // Let's implement "Totals for the requested period".
    
    final monthlySummary = MonthlyCashflow(
      totalSent: totalSent,
      totalReceived: totalReceived,
      netCashflow: totalReceived - totalSent,
      sentChangePercentage: 0, // Requires wider dataset comparison
      receivedChangePercentage: 0,
    );

    // 4. Category Analysis (Expenses)
    final categoryMap = <String, double>{};
    for (var e in expenses) {
      final key = e.category.name;
      categoryMap[key] = (categoryMap[key] ?? 0) + e.amount;
    }
    
    final expenseCategories = categoryMap.entries.map((e) => CategoryCashflow(
      categoryName: e.key,
      totalAmount: e.value,
      percentageOfTotal: totalSent > 0 ? (e.value / totalSent * 100) : 0,
      isCredit: false,
    )).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // 5. Income Source Analysis (Credits)
    final sourceMap = <String, double>{};
    for (var c in credits) {
      final key = c.senderId.isNotEmpty ? c.senderId : (c.merchantName ?? 'Unknown');
      sourceMap[key] = (sourceMap[key] ?? 0) + (c.amount ?? 0);
    }
    
    final incomeSources = sourceMap.entries.map((e) => CategoryCashflow(
      categoryName: e.key,
      totalAmount: e.value,
      percentageOfTotal: totalReceived > 0 ? (e.value / totalReceived * 100) : 0,
      isCredit: true,
    )).toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // 6. UPI Analysis
    // Merge debits (AutoTrans) and credits (AutoTrans) for UPI contact stats
    final upiMap = <String, _UpiAggregator>{};
    
    // Process Credits (Received From)
    for (var c in credits) {
      final name = c.senderId.isNotEmpty ? c.senderId : (c.merchantName ?? 'Unknown');
      upiMap.putIfAbsent(name, () => _UpiAggregator(name, true));
      upiMap[name]!.add(c.amount ?? 0);
    }
    
    // Process Debits (Sent To) - Using AutoTransactions implies capturing UPI debits not just manual expenses
    for (var d in debitTransactions) {
       // Only count if meaningful name available
       if (d.merchantName != null && d.merchantName!.isNotEmpty) {
         final name = d.merchantName!;
         upiMap.putIfAbsent(name, () => _UpiAggregator(name, false));
         upiMap[name]!.add(d.amount ?? 0);
       }
    }

    final topReceivers = upiMap.values
        .where((u) => !u.isMostlyCredit) // Sent TO
        .map((u) => u.toStats())
        .toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        
    final topSenders = upiMap.values
        .where((u) => u.isMostlyCredit) // Received FROM
        .map((u) => u.toStats())
        .toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));


    // 7. Daily Trends
    final dailyMap = <DateTime, _DailyAggregator>{};
    
    for (var e in expenses) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      dailyMap.putIfAbsent(date, () => _DailyAggregator(date));
      dailyMap[date]!.sent += e.amount;
    }
    
    for (var c in credits) {
      final d = c.receivedAt;
      final date = DateTime(d.year, d.month, d.day);
      dailyMap.putIfAbsent(date, () => _DailyAggregator(date));
      dailyMap[date]!.received += (c.amount ?? 0);
    }
    
    final dailyTrend = dailyMap.values.map((d) => d.toDailyCashflow()).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 8. Advanced Metrics
    final daysCount = endDate.difference(startDate).inDays + 1;
    final avgDailySpend = daysCount > 0 ? totalSent / daysCount : 0.0;
    final avgDailyIncome = daysCount > 0 ? totalReceived / daysCount : 0.0;
    final savingsRate = totalReceived > 0 ? ((totalReceived - totalSent) / totalReceived * 100) : 0.0;
    
    // Volatility (Stdev of daily spend)
    double varianceSum = 0;
    for (var d in dailyTrend) {
      varianceSum += pow(d.sent - avgDailySpend, 2);
    }
    final volatility = dailyTrend.isNotEmpty ? sqrt(varianceSum / dailyTrend.length) : 0.0;
    
    // Consistency (Stdev of daily income) - Note: Income is usually sparse (salary), so this might be high.
    // Lower means more consistent daily income.
    double incVarianceSum = 0;
    for (var d in dailyTrend) {
      incVarianceSum += pow(d.received - avgDailyIncome, 2);
    }
    final consistency = dailyTrend.isNotEmpty ? sqrt(incVarianceSum / dailyTrend.length) : 0.0;

    return FullCashflowReport(
      startDate: startDate,
      endDate: endDate,
      monthlySummary: monthlySummary,
      expenseCategories: expenseCategories,
      incomeSources: incomeSources,
      topReceivers: topReceivers,
      topSenders: topSenders,
      dailyTrend: dailyTrend,
      advancedMetrics: AdvancedMetrics(
        averageDailySpend: avgDailySpend,
        averageDailyIncome: avgDailyIncome,
        savingsRate: savingsRate,
        expenseVolatilityScore: volatility,
        incomeConsistencyScore: consistency,
      ),
    );
  }
}

class _UpiAggregator {
  final String name;
  final bool initialCredit; // Hint for primary role
  double amount = 0;
  int count = 0;
  double creditAmount = 0;
  double debitAmount = 0;

  _UpiAggregator(this.name, this.initialCredit);

  void add(double val) {
    amount += val;
    count++;
  }
  
  bool get isMostlyCredit => initialCredit; // Simplified logic

  UpiContactStats toStats() => UpiContactStats(
    name: name,
    totalAmount: amount,
    transactionCount: count,
    isReceiver: !initialCredit,
  );
}

class _DailyAggregator {
  final DateTime date;
  double sent = 0;
  double received = 0;
  
  _DailyAggregator(this.date);
  
  DailyCashflow toDailyCashflow() => DailyCashflow(
    date: date,
    sent: sent,
    received: received,
  );
}
