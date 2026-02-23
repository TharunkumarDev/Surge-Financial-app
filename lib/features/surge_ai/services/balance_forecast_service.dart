import '../domain/balance_forecast.dart';
import '../../expense/domain/expense_model.dart';

/// F4: Balance Forecast Service
/// Predicts end-of-month balance with deterministic calculations
class BalanceForecastService {
  /// Calculate month-end balance forecast
  Future<BalanceForecast> calculateMonthEndForecast({
    required List<ExpenseItem> expenses,
    required double currentBalance,
  }) async {
    
    // Get current month expenses
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
    
    if (thisMonthExpenses.isEmpty || currentBalance <= 0) {
      return BalanceForecast.insufficient();
    }
    
    // Calculate daily average spend
    final daysElapsed = now.day;
    final dailyAvgSpend = getDailyAverageSpend(thisMonthExpenses, daysElapsed);
    
    // Calculate remaining days in month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = lastDayOfMonth - now.day;
    
    // Project spending for remaining days
    final projectedSpending = projectSpending(dailyAvgSpend, daysRemaining);
    
    // Calculate forecast balance
    final forecastBalance = currentBalance - projectedSpending;
    
    // Detect risk level
    final riskLevel = _detectRiskLevel(forecastBalance);
    
    // Generate explanation
    final explanation = generateForecastExplanation(
      currentBalance: currentBalance,
      dailyAvgSpend: dailyAvgSpend,
      daysRemaining: daysRemaining,
      forecastBalance: forecastBalance,
      lastDayOfMonth: lastDayOfMonth,
    );
    
    // Generate recommendation if needed
    final recommendation = _generateRecommendation(
      currentBalance: currentBalance,
      forecastBalance: forecastBalance,
      dailyAvgSpend: dailyAvgSpend,
      daysRemaining: daysRemaining,
      riskLevel: riskLevel,
    );
    
    return BalanceForecast(
      currentBalance: currentBalance,
      dailyAverageSpend: dailyAvgSpend,
      daysRemaining: daysRemaining,
      projectedSpending: projectedSpending,
      forecastBalance: forecastBalance,
      riskLevel: riskLevel,
      explanation: explanation,
      generatedAt: DateTime.now(),
      recommendation: recommendation,
    );
  }
  
  /// Calculate daily average spending
  double getDailyAverageSpend(List<ExpenseItem> expenses, int daysElapsed) {
    if (daysElapsed <= 0) return 0;
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    return total / daysElapsed;
  }
  
  /// Project spending for remaining days
  double projectSpending(double dailyAvgSpend, int remainingDays) {
    return dailyAvgSpend * remainingDays;
  }
  
  /// Generate natural language forecast explanation
  String generateForecastExplanation({
    required double currentBalance,
    required double dailyAvgSpend,
    required int daysRemaining,
    required double forecastBalance,
    required int lastDayOfMonth,
  }) {
    final parts = <String>[];
    
    // Main forecast statement
    if (forecastBalance >= 0) {
      parts.add(
        'At this spending rate, your balance on the ${lastDayOfMonth}th will be '
        '₹${forecastBalance.toStringAsFixed(0)}.'
      );
    } else {
      parts.add(
        'Warning: At this spending rate, you may run out of money before month-end. '
        'Projected shortfall: ₹${forecastBalance.abs().toStringAsFixed(0)}.'
      );
    }
    
    // Daily average context
    parts.add(
      'You\'re spending an average of ₹${dailyAvgSpend.toStringAsFixed(0)} per day.'
    );
    
    return parts.join(' ');
  }
  
  /// Detect low balance risk
  bool detectLowBalanceRisk(double forecastBalance) {
    return forecastBalance < 1000;
  }
  
  /// Detect risk level
  ForecastRisk _detectRiskLevel(double forecastBalance) {
    if (forecastBalance < 0) {
      return ForecastRisk.critical;
    } else if (forecastBalance < 1000) {
      return ForecastRisk.low;
    } else if (forecastBalance < 5000) {
      return ForecastRisk.moderate;
    } else {
      return ForecastRisk.safe;
    }
  }
  
  /// Generate actionable recommendation
  String? _generateRecommendation({
    required double currentBalance,
    required double forecastBalance,
    required double dailyAvgSpend,
    required int daysRemaining,
    required ForecastRisk riskLevel,
  }) {
    if (daysRemaining <= 0) return null;
    
    switch (riskLevel) {
      case ForecastRisk.critical:
        // Calculate how much to reduce spending
        final targetBalance = 0.0; // At least break even
        final maxDailySpend = (currentBalance - targetBalance) / daysRemaining;
        final reduction = dailyAvgSpend - maxDailySpend;
        
        return 'To avoid running out of money, reduce daily spending by '
               '₹${reduction.toStringAsFixed(0)} to ₹${maxDailySpend.toStringAsFixed(0)}/day.';
        
      case ForecastRisk.low:
        // Suggest maintaining buffer
        final targetBalance = 1000.0;
        final targetDailySpend = (currentBalance - targetBalance) / daysRemaining;
        
        if (targetDailySpend > 0 && targetDailySpend < dailyAvgSpend) {
          return 'To maintain a ₹1,000 buffer, reduce daily spending to '
                 '₹${targetDailySpend.toStringAsFixed(0)}.';
        }
        return 'Try to reduce spending to build a safety buffer.';
        
      case ForecastRisk.moderate:
        final targetBalance = 5000.0;
        final targetDailySpend = (currentBalance - targetBalance) / daysRemaining;
        
        if (targetDailySpend > 0 && targetDailySpend < dailyAvgSpend) {
          return 'To maintain a ₹5,000 buffer, reduce daily spending to '
                 '₹${targetDailySpend.toStringAsFixed(0)}.';
        }
        return 'Consider reducing spending to build a larger safety buffer.';
        
      case ForecastRisk.safe:
        // Positive reinforcement
        final surplus = forecastBalance - 5000;
        if (surplus > 0) {
          return 'Great job! You\'re on track to save ₹${surplus.toStringAsFixed(0)} this month.';
        }
        return 'Your spending is well-managed. Keep it up!';
        
      case ForecastRisk.unknown:
        return null;
    }
  }
}
