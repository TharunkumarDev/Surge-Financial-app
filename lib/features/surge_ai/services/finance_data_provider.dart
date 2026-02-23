import 'package:intl/intl.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../expense/data/expense_repository.dart';
import '../../expense/domain/expense_model.dart';

/// Privacy-safe finance data aggregation service
/// Returns only aggregated numbers, no PII, no raw transaction details
class FinanceDataProvider {
  final WalletRepository walletRepository;
  final ExpenseRepository expenseRepository;
  
  FinanceDataProvider({
    required this.walletRepository,
    required this.expenseRepository,
  });
  
  /// Get current wallet balance
  Future<double> getCurrentBalance() async {
    return await walletRepository.getCurrentBalance();
  }
  
  /// Get total spending for current month
  Future<double> getMonthlySpending() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final expenses = await expenseRepository.getAllExpenses();
    final monthlyExpenses = expenses.where((e) => 
      e.date.isAfter(startOfMonth) && e.date.isBefore(endOfMonth)
    );
    
    return monthlyExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }
  
  /// Get total spending for current week
  Future<double> getWeeklySpending() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final expenses = await expenseRepository.getAllExpenses();
    final weeklyExpenses = expenses.where((e) => 
      e.date.isAfter(startOfWeekMidnight)
    );
    
    return weeklyExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }
  
  /// Get spending breakdown by category (privacy-safe aggregation)
  Future<Map<String, double>> getCategoryBreakdown({int? monthsBack}) async {
    final expenses = await expenseRepository.getAllExpenses();
    
    // Filter by time if specified
    List<ExpenseItem> filteredExpenses = expenses;
    if (monthsBack != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: monthsBack * 30));
      filteredExpenses = expenses.where((e) => e.date.isAfter(cutoffDate)).toList();
    }
    
    // Aggregate by category
    final Map<String, double> breakdown = {};
    for (final expense in filteredExpenses) {
      final category = expense.category.name;
      breakdown[category] = (breakdown[category] ?? 0.0) + expense.amount;
    }
    
    return breakdown;
  }
  
  /// Get recent transaction summary (aggregated, no details)
  Future<Map<String, dynamic>> getRecentTransactionsSummary({int limit = 5}) async {
    final expenses = await expenseRepository.getAllExpenses();
    final recent = expenses.take(limit).toList();
    
    return {
      'count': recent.length,
      'total': recent.fold<double>(0.0, (sum, e) => sum + e.amount),
      'average': recent.isEmpty ? 0.0 : recent.fold<double>(0.0, (sum, e) => sum + e.amount) / recent.length,
      'categories': recent.map((e) => e.category.name).toSet().toList(),
    };
  }
  
  /// Get wallet statistics
  Future<WalletStats> getWalletStats() async {
    return await walletRepository.getWalletStats();
  }
  
  /// Get formatted currency string
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return formatter.format(amount);
  }
  
  /// Get spending trend (privacy-safe comparison)
  Future<Map<String, dynamic>> getSpendingTrend() async {
    final thisMonth = await getMonthlySpending();
    
    // Get last month spending
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    
    final expenses = await expenseRepository.getAllExpenses();
    final lastMonthExpenses = expenses.where((e) => 
      e.date.isAfter(lastMonthStart) && e.date.isBefore(lastMonthEnd)
    );
    final lastMonth = lastMonthExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    
    final change = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth) * 100 : 0.0;
    
    return {
      'thisMonth': thisMonth,
      'lastMonth': lastMonth,
      'changePercent': change,
      'trend': change > 0 ? 'increased' : change < 0 ? 'decreased' : 'stable',
    };
  }
  
  /// Get all expenses (for advanced AI services)
  Future<List<ExpenseItem>> getExpenses() async {
    return await expenseRepository.getAllExpenses();
  }
  
  /// Get current balance (for advanced AI services)
  Future<double> getBalance() async {
    return await walletRepository.getCurrentBalance();
  }
}
