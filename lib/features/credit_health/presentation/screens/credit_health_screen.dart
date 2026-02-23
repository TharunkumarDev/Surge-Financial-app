import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_system.dart';
import '../providers/credit_health_providers.dart';
import '../../domain/entities/credit_health_score.dart';

class CreditHealthScreen extends ConsumerWidget {
  const CreditHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(creditHealthScoreProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text("Credit Health", style: TextStyle(color: isDark ? Colors.white : AppTheme.darkGreen)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
          onPressed: () => context.pop(),
        ),
      ),
      body: scoreAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.limeAccent)),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: Colors.red))),
        data: (creditHealth) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Score Gauge Card
              _buildScoreCard(context, creditHealth, isDark),
              
              const SizedBox(height: AppSpacing.lg),
              
              // 2. AI Insight
              _buildAIInsight(context, creditHealth, isDark),
              
              const SizedBox(height: AppSpacing.lg),
              
              // 3. Factors Breakdown
              Text("Score Factors", style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : AppTheme.darkGreen,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: AppSpacing.sm),
              _buildFactorRow(context, "Payment Punctuality", creditHealth.paymentPunctuality, isDark),
              _buildFactorRow(context, "Credit Utilization", creditHealth.creditUtilization, isDark),
              _buildFactorRow(context, "Savings Health", creditHealth.savingsHealth, isDark),
              _buildFactorRow(context, "Spending Stability", creditHealth.spendingStability, isDark),
              _buildFactorRow(context, "Credit Mix & Age", creditHealth.creditMix, isDark),
              
              const SizedBox(height: AppSpacing.xl),
              
              // 4. Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: isDark ? Colors.white54 : Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "This score is an AI-based financial health estimate, not an official credit score from a bureau.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, CreditHealthScore creditHealth, bool isDark) {
    Color scoreColor;
    switch(creditHealth.category) {
      case CreditHealthCategory.poor: scoreColor = Colors.redAccent; break;
      case CreditHealthCategory.fair: scoreColor = Colors.orangeAccent; break;
      case CreditHealthCategory.good: scoreColor = Colors.yellowAccent; break;
      case CreditHealthCategory.veryGood: scoreColor = AppTheme.limeAccent; break;
      case CreditHealthCategory.excellent: scoreColor = Colors.greenAccent; break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.premiumGradient, // Use theme gradient or custom dark card
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Text(
            "ESTIMATED SCORE",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: AppTheme.darkGreen.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${creditHealth.score}",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 72,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGreen,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getCategoryLabel(creditHealth.category),
              style: const TextStyle(
                color: AppTheme.limeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(CreditHealthCategory category) {
    switch(category) {
      case CreditHealthCategory.poor: return "POOR";
      case CreditHealthCategory.fair: return "FAIR";
      case CreditHealthCategory.good: return "GOOD";
      case CreditHealthCategory.veryGood: return "VERY GOOD";
      case CreditHealthCategory.excellent: return "EXCELLENT";
    }
  }

  Widget _buildAIInsight(BuildContext context, CreditHealthScore creditHealth, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.limeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/surge_logo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.auto_awesome, 
                      color: AppTheme.limeAccent, 
                      size: 20
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "AI Insights",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            creditHealth.aiExplanation ?? "Analyzing your financial patterns...",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorRow(BuildContext context, String label, double value, bool isDark) {
    // Value is 0-100
    Color barColor;
    if (value >= 80) barColor = AppTheme.limeAccent;
    else if (value >= 50) barColor = Colors.orangeAccent;
    else barColor = Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getFactorStatus(value),
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _getFactorStatus(double value) {
    if (value >= 80) return "Excellent";
    if (value >= 60) return "Good";
    if (value >= 40) return "Fair";
    return "Needs Work";
  }
}
