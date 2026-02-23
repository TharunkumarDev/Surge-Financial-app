import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/providers/currency_provider.dart';
import '../../expense/data/expense_repository.dart';
import '../../expense/domain/expense_model.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../subscription/services/entitlement_service.dart';
import '../../subscription/presentation/widgets/upgrade_dialog.dart';
import '../../subscription/presentation/widgets/modern_paywall_dialog.dart';
import '../../subscription/domain/feature_entitlement.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/providers/wallet_providers.dart'; 
import '../services/ai_insight_service.dart';
import '../providers/analytics_providers.dart';
import '../services/report_generator.dart';
import '../../auto_tracking/providers/auto_tracking_providers.dart';
import 'widgets/sms_analytics_widgets.dart';
import '../../../core/services/sync_coordinator.dart';
import '../../expense/providers/expense_providers.dart';
import '../../loan/providers/loan_providers.dart';
import '../../loan/domain/loan_model.dart';
import '../../subscription/providers/subscription_tracker_providers.dart';
import '../../subscription/domain/subscription_model.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
import '../../auto_tracking/domain/auto_transaction.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedTimeRange = 'Month';

  List<ExpenseItem> _filterExpenses(List<ExpenseItem> allExpenses) {
    final now = DateTime.now();
    return allExpenses.where((e) {
      if (_selectedTimeRange == 'Day') {
        return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
      } else if (_selectedTimeRange == 'Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final date = DateTime(e.date.year, e.date.month, e.date.day);
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
        return (date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                date.isBefore(end.add(const Duration(days: 1))));
      } else if (_selectedTimeRange == 'Month') {
        return e.date.year == now.year && e.date.month == now.month;
      } else if (_selectedTimeRange == 'Year') {
        return e.date.year == now.year;
      }
      return true; // Loans/Subs don't filter expenses this way, but this helper is for expenses
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Check Pro Access
    final tier = ref.watch(currentSubscriptionTierProvider);
    final entitlement = ref.watch(entitlementServiceProvider);
    final currency = ref.watch(currencyProvider);
    
    if (!entitlement.hasAccess(AppFeature.viewAnalytics, tier)) {
      return const _AnalyticsUpgradeView();
    }

    final expensesAsync = ref.watch(expenseListProvider);
    final statsAsync = ref.watch(currentWalletStatsProvider);
    final smsTransactionsAsync = ref.watch(pendingTransactionsProvider);
    final loansAsync = ref.watch(activeLoansProvider);
    final subsAsync = ref.watch(subscriptionsStreamProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text("Analytics", style: TextStyle(color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
            onPressed: () {
               expensesAsync.whenData((expenses) {
                 // Enhanced export logic could go here
                 final filtered = _filterExpenses(expenses);
                 if (filtered.isEmpty && _selectedTimeRange != 'Loans' && _selectedTimeRange != 'Subs') {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to report for this period")));
                   return;
                 }
                 ReportGenerator.generateAndDownload(filtered, statsAsync.valueOrNull ?? WalletStats(income:0,expenses:0,remaining:0), _selectedTimeRange, currency.symbol);
               });
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final stats = statsAsync.valueOrNull ?? WalletStats(income: 0, expenses: 0, remaining: 0);
          final loans = loansAsync; // Provider<List>
          final subs = subsAsync.valueOrNull ?? [];
          
          final filteredExpenses = _filterExpenses(expenses);
          final hasData = filteredExpenses.isNotEmpty;
          
          return RefreshIndicator(
            onRefresh: () async {
              try {
                final coordinator = await ref.read(syncCoordinatorProvider.future);
                await coordinator?.sync(force: true);
                ref.invalidate(expenseRepositoryProvider);
                ref.invalidate(allExpensesProvider);
                ref.invalidate(walletRepositoryProvider);
                ref.invalidate(currentWalletStatsProvider);
                // Also invalidate loans/subs if possible
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Refresh failed: $e')),
                  );
                }
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Time Range Selector
                  _TimeRangeSelector(
                    selected: _selectedTimeRange,
                    onChanged: (val) => setState(() => _selectedTimeRange = val),
                  ),
                  const SizedBox(height: 24),
                  
                  // Content based on selection
                  if (_selectedTimeRange == 'Loans')
                     _buildLoansView(loans, currency.symbol, isDark)
                  else if (_selectedTimeRange == 'Subs')
                     _buildSubsView(subs, currency.symbol, isDark)
                  else
                     _buildExpensesView(filteredExpenses, stats, hasData, currency.symbol, smsTransactionsAsync),
                  
                  const SizedBox(height: 120), // Added padding for floating navbar
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildExpensesView(List<ExpenseItem> filteredExpenses, WalletStats stats, bool hasData, String currencySymbol, AsyncValue<List<dynamic>> smsTransactionsAsync) {
    return Column(
      children: [
        // Spending Insights (Donut)
        _SpendingInsightsCard(expenses: filteredExpenses, hasData: hasData, currencySymbol: currencySymbol),
        const SizedBox(height: 24),
        
        // Weekly Bar Chart
        _WeeklySpendingChart(expenses: filteredExpenses, hasData: hasData),
        const SizedBox(height: 24),
        
        // Spend Gauge
        _SpendPercentageGauge(stats: stats, hasData: hasData, currencySymbol: currencySymbol),
        const SizedBox(height: 24),
        
        // SMS Tracking Analytics Section
        smsTransactionsAsync.when(
          data: (transactions) => SmsAnalyticsSection(
            transactions: transactions.cast<AutoTransaction>().toList(),
            currencySymbol: currencySymbol,
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLoansView(List<LoanModel> loans, String currencySymbol, bool isDark) {
    return Column(
      children: [
        // Debt Distribution Pie
        _LoanDistributionCard(loans: loans, currencySymbol: currencySymbol),
        const SizedBox(height: 24),
        
        // Repayment Progress
        _LoanProgressCard(loans: loans, currencySymbol: currencySymbol),
      ],
    );
  }

  Widget _buildSubsView(List<SubscriptionModel> subs, String currencySymbol, bool isDark) {
    return Column(
      children: [
        // Subscription Cost Distribution
        _SubscriptionCostCard(subs: subs, currencySymbol: currencySymbol),
        const SizedBox(height: 24),
        
        // Top Subscriptions
        _TopSubscriptionsCard(subs: subs, currencySymbol: currencySymbol),
      ],
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TimeRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ranges = ['Day', 'Week', 'Month', 'Year', 'Loans', 'Subs'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ranges.map((range) {
            final isSelected = range == selected;
            return GestureDetector(
              onTap: () => onChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.limeAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected 
                      ? AppTheme.darkGreen 
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey.shade600),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SpendingInsightsCard extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final bool hasData;
  final String currencySymbol;

  const _SpendingInsightsCard({required this.expenses, required this.hasData, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Group by category
    final totals = <ExpenseCategory, double>{};
    double totalSpent = 0;
    
    if (hasData) {
      for (var e in expenses) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
        totalSpent += e.amount;
      }
    } else {
      // Placeholder data for empty state
      totals[ExpenseCategory.food] = 1; 
      totals[ExpenseCategory.shopping] = 1;
      totals[ExpenseCategory.entertainment] = 1;
      totalSpent = 3;
    }

    // Sort by amount desc
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    // Pie Chart Sections
    final sections = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value.key;
      final amount = entry.value.value;
      
      final color = hasData 
          ? _getCategoryColor(index) 
          : Colors.grey.withOpacity(0.2 + (index * 0.1)); // Shades of grey for empty
      
      return PieChartSectionData(
        value: amount,
        color: color,
        radius: 25,
        showTitle: false,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spending Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Text("In 1 Month v", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (hasData)
             ...sortedEntries.take(4).map((e) {
               final pct = (e.value / totalSpent * 100).toStringAsFixed(1);
               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 6),
                 child: Row(
                   children: [
                     Container(
                       width: 6, height: 6,
                       decoration: BoxDecoration(shape: BoxShape.circle, color: _getCategoryColor(sortedEntries.indexOf(e))),
                     ),
                     const SizedBox(width: 8),
                     Text(e.key.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
                     const Spacer(),
                     Text("$pct%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                   ],
                 ),
               );
             })
          else
            // Empty State Legend
             ...List.generate(4, (i) => Padding(
               padding: const EdgeInsets.symmetric(vertical: 6),
               child: Row(
                 children: [
                   Container(
                     width: 6, height: 6,
                     decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withOpacity(0.3)),
                   ),
                   const SizedBox(width: 8),
                   Container(width: 60, height: 10, color: Colors.grey.withOpacity(0.1)),
                   const Spacer(),
                   Container(width: 30, height: 10, color: Colors.grey.withOpacity(0.1)),
                 ],
               ),
             )),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFFFF6B6B), // Red/Orange
      Color(0xFFFFD93D), // Yellow
      Color(0xFF6BCB77), // Green
      Color(0xFF4D96FF), // Blue
      Color(0xFF9D4EDD), // Purple
    ];
    return colors[index % colors.length];
  }
}

class _WeeklySpendingChart extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final bool hasData;

  const _WeeklySpendingChart({required this.expenses, required this.hasData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 0 = Mon, 6 = Sun
    final double weekendSpend = hasData 
        ? expenses.where((e) => e.date.weekday >= 6).fold(0, (sum, e) => sum + e.amount)
        : 0;
    final double totalSpend = hasData ? expenses.fold(0, (sum, e) => sum + e.amount) : 1;
    final int weekendPct = hasData ? ((weekendSpend / totalSpend) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$weekendPct%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
          Text("Spent on weekends", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: hasData ? null : 10, // Default max for empty
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (val.toInt() >= 0 && val.toInt() < days.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(days[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                           );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  // Real calculation would go here, mock/empty for now if !hasData
                  final dayReal = hasData 
                      ? expenses.where((e) => e.date.weekday == index + 1).fold(0.0, (s, e) => s + e.amount)
                      : (index > 4 ? 6.0 : 3.0); // Fake empty pattern
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dayReal,
                        color: hasData 
                            ? AppTheme.limeAccent 
                            : Colors.grey.withOpacity(0.2), // Grey for empty
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                            show: true, 
                            toY: hasData ? (expenses.isEmpty ? 10 : null) : 10, 
                            color: Colors.transparent
                        ), 
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendPercentageGauge extends StatelessWidget {
  final WalletStats stats;
  final bool hasData;
  final String currencySymbol;

  const _SpendPercentageGauge({required this.stats, required this.hasData, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    // Calculate percentage (Spent / Total Possible i.e. Income + Spent?? Or just Spending Limit?)
    // Using Spent / (Spent + Remaining) which is basically Income.
    final total = stats.income;
    final spent = stats.expenses;
    final percentage = hasData && total > 0 ? (spent / total * 100).clamp(0, 100) : 0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text("Spend Percentage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
               Text("In 1 Month v", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
             ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 180,
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: [
                      // Gauge Value
                      PieChartSectionData(
                        value: hasData ? percentage.toDouble() : 40, // 40% visual placeholder if empty
                        color: hasData ? _getGaugeColor(percentage) : Colors.grey.withOpacity(0.2),
                        radius: 12,
                        showTitle: false,
                      ),
                      // Gauge Background
                      PieChartSectionData(
                        value: 100 - (hasData ? percentage.toDouble() : 40),
                        color: Colors.grey.withOpacity(0.1),
                        radius: 12,
                        showTitle: false,
                      ),
                      // Bottom Half Hidden
                      PieChartSectionData(
                        value: 100,
                        color: Colors.transparent,
                        radius: 12,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${hasData ? percentage.toStringAsFixed(0) : 0}%",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    Text(
                      "By Total Balance",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppTheme.greyText),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "0 $currencySymbol", 
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.limeAccent : AppTheme.darkGreen)
              ),
              Text(
                "${total.toStringAsFixed(0)} $currencySymbol", 
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.limeAccent : AppTheme.darkGreen)
              ),
            ],
          ),
           const SizedBox(height: 24),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
             child: Row(
               children: [
                 Icon(Icons.savings_outlined, color: AppTheme.greyText, size: 20),
                 const SizedBox(width: 8),
                 Text("Your spend is", style: TextStyle(color: AppTheme.greyText)),
                 const Spacer(),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                   decoration: BoxDecoration(
                     color: hasData ? AppTheme.limeAccent : Colors.grey.withOpacity(0.2),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     hasData ? ((percentage as num) < 50 ? "Healthy" : "Attention") : "No Data",
                     style: TextStyle(
                       fontWeight: FontWeight.bold, 
                       color: hasData ? AppTheme.darkGreen : Colors.grey,
                     ),
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }
  
  Color _getGaugeColor(num percentage) {
    if (percentage < 40) return AppTheme.limeAccent;
    if (percentage < 70) return Colors.orange;
    return Colors.red;
  }
}

class _AnalyticsUpgradeView extends StatelessWidget {
  const _AnalyticsUpgradeView();

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Analytics")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: AppTheme.greyText.withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                Text(
                  "Analytics is a PRO feature",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Upgrade your plan to see detailed spending insights and category breakdowns.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.greyText),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        useRootNavigator: true,
                        builder: (context) => const ModernPaywallDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.limeAccent,
                      foregroundColor: AppTheme.darkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Upgrade Now"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _LoanDistributionCard extends StatelessWidget {
  final List<LoanModel> loans;
  final String currencySymbol;

  const _LoanDistributionCard({required this.loans, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = loans.isNotEmpty;
    final sections = <PieChartSectionData>[];
    
    if (hasData) {
      final totalDebt = loans.fold(0.0, (sum, l) => sum + l.remainingAmount);
      for (int i = 0; i < loans.length; i++) {
        final loan = loans[i];
        final pct = totalDebt > 0 ? (loan.remainingAmount / totalDebt * 100) : 0.0;
        sections.add(
          PieChartSectionData(
            value: pct,
            color: _getChartColor(i),
            radius: 25,
            showTitle: false,
          ),
        );
      }
    } else {
      sections.add(PieChartSectionData(value: 100, color: Colors.grey.withValues(alpha: 0.2), radius: 25, showTitle: false));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Debt Structure", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              if (hasData)
                Text("Total: ${loans.fold(0.0, (s, l) => s + l.remainingAmount).toStringAsFixed(0)} $currencySymbol", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (hasData)
             ...loans.take(4).map((l) {
               final index = loans.indexOf(l);
               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 6),
                 child: Row(
                   children: [
                     Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _getChartColor(index))),
                     const SizedBox(width: 8),
                     Text(l.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                     const Spacer(),
                     Text("${l.remainingAmount.toStringAsFixed(0)} $currencySymbol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                   ],
                 ),
               );
             })
          else
            const Center(child: Text("No active loans", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _LoanProgressCard extends StatelessWidget {
  final List<LoanModel> loans;
  final String currencySymbol;

  const _LoanProgressCard({required this.loans, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Repayment Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          if (loans.isEmpty)
             const Padding(
               padding: EdgeInsets.all(20.0),
               child: Center(child: Text("No loans to track", style: TextStyle(color: Colors.grey))),
             )
          else
            ...loans.map((l) {
              final paid = l.totalAmount - l.remainingAmount;
              final progress = l.totalAmount > 0 ? (paid / l.totalAmount).clamp(0.0, 1.0) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                        Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(color: AppTheme.limeAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(AppTheme.limeAccent),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Paid: ${paid.toStringAsFixed(0)} / ${l.totalAmount.toStringAsFixed(0)} $currencySymbol",
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SubscriptionCostCard extends StatelessWidget {
  final List<SubscriptionModel> subs;
  final String currencySymbol;

  const _SubscriptionCostCard({required this.subs, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = subs.isNotEmpty;
    final sections = <PieChartSectionData>[];
    
    if (hasData) {
      final totalCost = subs.fold(0.0, (sum, s) => sum + s.amount);
      for (int i = 0; i < subs.length; i++) {
        final sub = subs[i];
        final pct = totalCost > 0 ? (sub.amount / totalCost * 100) : 0.0;
        sections.add(
          PieChartSectionData(
            value: pct,
            color: _getChartColor(i),
            radius: 25,
            showTitle: false,
          ),
        );
      }
    } else {
      sections.add(PieChartSectionData(value: 100, color: Colors.grey.withValues(alpha: 0.2), radius: 25, showTitle: false));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly Cost", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              if (hasData)
                Text("Total: ${subs.fold(0.0, (s, sub) => s + sub.amount).toStringAsFixed(0)} $currencySymbol", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (hasData)
             ...subs.take(4).map((s) {
               final index = subs.indexOf(s);
               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 6),
                 child: Row(
                   children: [
                     Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _getChartColor(index))),
                     const SizedBox(width: 8),
                     Text(s.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                     const Spacer(),
                     Text("${s.amount.toStringAsFixed(0)} $currencySymbol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                   ],
                 ),
               );
             })
          else
            const Center(child: Text("No subscriptions", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _TopSubscriptionsCard extends StatelessWidget {
  final List<SubscriptionModel> subs;
  final String currencySymbol;

  const _TopSubscriptionsCard({required this.subs, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = List<SubscriptionModel>.from(subs)..sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Subscriptions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          if (sorted.isEmpty)
             const Padding(
               padding: EdgeInsets.all(20.0),
               child: Center(child: Text("No subscriptions", style: TextStyle(color: Colors.grey))),
             )
          else
            ...sorted.take(5).map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.subscriptions_outlined, size: 16, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                        Text(s.billingCycle.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Text("${s.amount.toStringAsFixed(0)} $currencySymbol", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

Color _getChartColor(int index) {
  const colors = [
    Color(0xFFFF6B6B), // Red/Orange
    Color(0xFFFFD93D), // Yellow
    Color(0xFF6BCB77), // Green
    Color(0xFF4D96FF), // Blue
    Color(0xFF9D4EDD), // Purple
  ];
  return colors[index % colors.length];
}
