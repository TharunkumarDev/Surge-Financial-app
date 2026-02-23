import 'package:flutter/foundation.dart';
import '../../../expense/domain/expense_model.dart';
import '../../../subscription/domain/subscription_reminder.dart';
import '../../../subscription/domain/subscription_plan.dart';
import '../../domain/entities/credit_health_score.dart';
import 'dart:math' as math;

class CreditScoringEngine {
  /// Calculate Credit Health Score (0-900)
  ///
  /// Factors:
  /// 1. Payment Punctuality (35%) - No overdue subscriptions/bills
  /// 2. Credit Utilization (30%) - Fixed Costs / Income
  /// 3. Savings Health (15%) - Savings Rate
  /// 4. Spending Stability (10%) - Variance in discretionary spending
  /// 5. Credit Mix/Age (10%) - App usage duration & variety
  CreditHealthScore calculateScore({
    required List<ExpenseItem> expenses,
    required List<SubscriptionReminder> subscriptions,
    required double monthlyIncome,
    required DateTime accountCreationDate,
  }) {
    if (monthlyIncome <= 0) {
      return CreditHealthScore.initial();
    }

    // 1. Calculate Factors (0-100 scale)
    final paymentPunctuality = _calculatePaymentPunctuality(subscriptions, expenses);
    final creditUtilization = _calculateCreditUtilization(expenses, subscriptions, monthlyIncome);
    final savingsHealth = _calculateSavingsHealth(expenses, monthlyIncome);
    final spendingStability = _calculateSpendingStability(expenses);
    final creditMix = _calculateCreditMix(expenses, accountCreationDate);

    // 2. Weighted Sum
    double rawScore = 
      (paymentPunctuality * 0.35) +
      (creditUtilization * 0.30) +
      (savingsHealth * 0.15) +
      (spendingStability * 0.10) +
      (creditMix * 0.10);

    // 3. Normalize to 300-900 (Typical Credit Score Range)
    // Scale 0-100 to 300-900
    // formula: 300 + (rawScore * 6)
    int finalScore = (300 + (rawScore * 6)).round().clamp(300, 900);

    return CreditHealthScore(
      score: finalScore,
      category: _getCategory(finalScore),
      calculatedAt: DateTime.now(),
      paymentPunctuality: paymentPunctuality,
      creditUtilization: creditUtilization,
      savingsHealth: savingsHealth,
      spendingStability: spendingStability,
      creditMix: creditMix,
      aiExplanation: null, // Populated by AI service layer
    );
  }

  CreditHealthCategory _getCategory(int score) {
    if (score >= 800) return CreditHealthCategory.excellent;
    if (score >= 750) return CreditHealthCategory.veryGood;
    if (score >= 650) return CreditHealthCategory.good;
    if (score >= 500) return CreditHealthCategory.fair;
    return CreditHealthCategory.poor;
  }

  double _calculatePaymentPunctuality(List<SubscriptionReminder> subs, List<ExpenseItem> expenses) {
    // Assumption: If subscription is active and not expired, it's "punctual".
    // Also check for "Late Fees" in expenses.
    
    if (subs.isEmpty) return 80.0; // Neutral start
    
    int total = subs.length;
    int onTime = subs.where((s) => s.isActive).length;
    
    // Penalize for "Late Fee" expenses
    int lateFees = expenses.where((e) => 
      e.title.toLowerCase().contains('late') && 
      e.title.toLowerCase().contains('fee')
    ).length;

    double score = (onTime / total) * 100;
    score -= (lateFees * 10); // Deduct 10 points per late fee
    
    return score.clamp(0.0, 100.0);
  }

  double _calculateCreditUtilization(List<ExpenseItem> expenses, List<SubscriptionReminder> subs, double income) {
    // Fixed Costs = Rent + EMI + Subscriptions
    // We infer Rent/EMI from keywords
    
    double fixedCosts = 0;
    
    // Sum Subscriptions (Approximation: Plan cost is not directly in Reminder, need to fetch from Plan... 
    // Data limit: SubscriptionReminder doesn't have cost. 
    // Mitigation: Assume average cost ₹500 for now or rely on "Subscription" category expenses)
    
    // Better Approach: Sum expenses with category "Utilities", "Rent", "EMI"
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyExpenses = expenses.where((e) => 
      e.date.month == currentMonth && e.date.year == currentYear
    );

    for (var e in monthlyExpenses) {
      if (e.category == ExpenseCategory.utilities || 
          e.title.toLowerCase().contains('rent') ||
          e.title.toLowerCase().contains('emi') ||
          e.title.toLowerCase().contains('loan')) {
        fixedCosts += e.amount;
      }
    }

    // Include recurring expenses
    fixedCosts += monthlyExpenses.where((e) => e.isRecurring).fold(0.0, (sum, e) => sum + e.amount);

    double utilizationRatio = fixedCosts / income;
    
    // Inverse Logic: Lower utilization is better, but up to a point.
    // 0-30% is Excellent (100)
    // 30-50% is Good (80)
    // 50-70% is Fair (50)
    // >70% is Poor (20)
    
    if (utilizationRatio <= 0.30) return 100;
    if (utilizationRatio <= 0.50) return 85;
    if (utilizationRatio <= 0.70) return 60;
    return 30;
  }

  double _calculateSavingsHealth(List<ExpenseItem> expenses, double income) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final totalSpent = expenses
      .where((e) => e.date.month == currentMonth && e.date.year == currentYear)
      .fold(0.0, (sum, e) => sum + e.amount);
      
    double savings = income - totalSpent;
    double savingsRate = savings / income;
    
    // Target: 20% savings
    if (savingsRate >= 0.20) return 100;
    if (savingsRate >= 0.10) return 80;
    if (savingsRate > 0) return 60;
    return 20; // Negative or zero savings
  }

  double _calculateSpendingStability(List<ExpenseItem> expenses) {
    // Check variance of weekly spending
    // Simplified: Just check if there are massive spikes (> 2x average)
    if (expenses.isEmpty) return 100;
    
    double total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    double avg = total / expenses.length;
    
    int spikes = expenses.where((e) => e.amount > (avg * 3)).length;
    
    // 100 - (10 points per spike)
    return (100.0 - (spikes * 10)).clamp(0.0, 100.0);
  }

  double _calculateCreditMix(List<ExpenseItem> expenses, DateTime creationDate) {
    // 1. Account Age
    final daysSinceCreation = DateTime.now().difference(creationDate).inDays;
    double ageScore = (daysSinceCreation / 365) * 100; // 1 year = 100 points
    
    // 2. Category Variety
    final uniqueCategories = expenses.map((e) => e.category).toSet().length;
    double mixScore = (uniqueCategories / ExpenseCategory.values.length) * 100;
    
    return ((ageScore * 0.6) + (mixScore * 0.4)).clamp(0.0, 100.0);
  }
}
