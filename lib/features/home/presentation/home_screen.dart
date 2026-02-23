import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/currency_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/isar_provider.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/data/expense_repository.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../profile/domain/user_model.dart';
import '../../profile/data/user_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../subscription/services/entitlement_service.dart';
import '../../subscription/presentation/widgets/upgrade_dialog.dart';
import '../../auto_tracking/providers/auto_tracking_providers.dart';
import '../../auto_tracking/presentation/detected_transaction_dialog.dart';
import '../../wallet/providers/wallet_providers.dart';
import 'widgets/flippable_balance_card.dart';
import '../../ai_bill_scanner/presentation/screens/bill_camera_screen.dart';
import '../../expense/providers/expense_providers.dart';
import '../../profile/providers/user_provider.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
import '../../../core/services/sync_coordinator.dart';
import '../../subscription/providers/subscription_tracker_providers.dart';
import '../../loan/providers/loan_providers.dart';
import '../../loan/domain/loan_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(recentExpensesProvider);
    final statsAsync = ref.watch(currentWalletStatsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final pendingTransactionsAsync = ref.watch(pendingTransactionsProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              final coordinator = await ref.read(syncCoordinatorProvider.future);
              await coordinator?.sync(force: true);
              ref.invalidate(currentWalletStatsProvider);
              ref.invalidate(recentExpensesProvider);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Refresh failed: $e')),
                );
              }
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userAsync.when(
                            data: (user) => Text(
                              "Hi, ${user?.username ?? 'User'}",
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            loading: () => const Text("Hi, User"),
                            error: (_, __) => const Text("Hi, User"),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Welcome Back!",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                      const _ProfileButton(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Detected SMS Transactions Banner
              _DetectedTransactionBanner(pendingTransactionsAsync: pendingTransactionsAsync),

              // Wallet Balance Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: statsAsync.when(
                    data: (stats) => FlippableBalanceCard(
                      stats: stats,
                      currencySymbol: currency.symbol,
                      onTap: () => _showBalanceSettings(context, ref, currency.symbol),
                      ref: ref,
                    ),
                    loading: () => FlippableBalanceCard(
                      stats: WalletStats(income: 0, expenses: 0, remaining: 0),
                      currencySymbol: currency.symbol,
                      onTap: () {},
                      ref: ref,
                    ),
                    error: (_, __) => FlippableBalanceCard(
                      stats: WalletStats(income: 0, expenses: 0, remaining: 0),
                      currencySymbol: currency.symbol,
                      onTap: () {},
                      ref: ref,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // Quick Spending Status
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _QuickSpendingStatus(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Bill Scanner Card
              const _BillScannerCard(),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Add Expense Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/add-expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGreen,
                        foregroundColor: AppTheme.limeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Add Expense',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.limeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // Upcoming Subscription Card
              _UpcomingSubscriptionCard(),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Loan Due Card
              _LoanDueCard(),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // Recent Activity Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Activity",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/analytics'),
                        child: Text(
                          "See Details >",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.greyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Recent Expenses List
              expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: AppTheme.greyText.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                                Text(
                                  "No expenses yet",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white60 : AppTheme.greyText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenses[index];
                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.destructive,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                title: const Text("Delete Transaction?"),
                                content: const Text("Are you sure you want to delete this transaction? This action cannot be undone."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancel", style: TextStyle(color: AppTheme.greyText)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Delete", style: TextStyle(color: AppTheme.destructive, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) async {
                            try {
                              final repo = await ref.read(expenseRepositoryProvider.future);
                              await repo.deleteExpense(expense.id);
                            } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting: $e')),
                                  );
                                }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 8,
                            ),
                            child: _ExpenseRow(expense: expense),
                          ),
                        );
                      },
                      childCount: expenses.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, st) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Error loading expenses',
                        style: TextStyle(color: AppTheme.greyText),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  void _showBalanceSettings(BuildContext context, WidgetRef ref, String currencySymbol) {
    final controller = TextEditingController();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add Salary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.darkGreen, 
                fontWeight: FontWeight.w600
              ),
              decoration: InputDecoration(
                labelText: 'Salary Amount',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : AppTheme.greyText),
                prefixText: '$currencySymbol ',
                prefixStyle: TextStyle(
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen, 
                  fontWeight: FontWeight.bold
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.greyText.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen, 
                    width: 2
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : AppTheme.backgroundLight,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : AppTheme.darkGreen,
                    side: BorderSide(color: isDark ? Colors.white24 : AppTheme.darkGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text) ?? 0.0;
                    try {
                      final repo = await ref.read(walletRepositoryProvider.future);
                      await repo.setInitialBalance(amount);
                      ref.invalidate(currentWalletStatsProvider);
                      if (context.mounted) Navigator.pop(context);
                    } on InsufficientPermissionException catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (context) => UpgradeDialog(
                            featureName: e.featureName,
                            minimumTier: e.minimumTier,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkGreen,
                    foregroundColor: AppTheme.limeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(
          Icons.person_rounded, 
          size: 24,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _WalletBalanceCard extends StatefulWidget {
  final WalletStats stats;
  final String currencySymbol;
  final VoidCallback onTap;
  final WidgetRef ref;

  const _WalletBalanceCard({
    required this.stats,
    required this.currencySymbol,
    required this.onTap,
    required this.ref,
  });

  @override
  State<_WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<_WalletBalanceCard> with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showFront) {
      _flipController.forward().then((_) {
        setState(() => _showFront = false);
      });
    } else {
      _flipController.reverse().then((_) {
        setState(() => _showFront = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format percentages to remove trailing zeros (e.g., 24% instead of 24.00%)
    final savingsFormatted = widget.stats.savingsPercentage.toStringAsFixed(0);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.limeAccent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Eye & Menu Icons (Aligned Right)
          // Top Row: Eye & Menu Icons (Aligned Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: AppTheme.darkGreen, size: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearBalanceDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services_outlined, color: AppTheme.destructive, size: 20),
                        SizedBox(width: 8),
                        Text('Clear Balance', style: TextStyle(color: AppTheme.destructive)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Remaining Balance Amount (Top Heavy)
          Text(
            _isBalanceVisible 
                ? '${widget.currencySymbol}${widget.stats.remaining.toStringAsFixed(2)}' 
                : '${widget.currencySymbol} ****',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGreen,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          
          // Label for the big number
           Text(
             'Remaining Amount',
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: AppTheme.darkGreen.withOpacity(0.7),
               fontWeight: FontWeight.w600,
             ),
           ),

          const SizedBox(height: 16),
          
          // Savings Rate / Percentage Comparison
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 16,
                  color: AppTheme.darkGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  '$savingsFormatted%',
                  style: TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Savings Rate',
                  style: TextStyle(
                    color: AppTheme.darkGreen.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Total Balance (Income) Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: AppTheme.darkGreen.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _isBalanceVisible 
                    ? '${widget.currencySymbol}${widget.stats.income.toStringAsFixed(2)}'
                    : '${widget.currencySymbol} ****',
                style: TextStyle(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action Buttons - Add Salary
         SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                foregroundColor: AppTheme.limeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.add_circle_outline, size: 20),
                   const SizedBox(width: 8),
                   Text(
                    'Add Salary',
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                       color: AppTheme.limeAccent,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearBalanceDialog(BuildContext context) {
    bool clearSalary = true;
    bool clearExpenses = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              "Clear Balance", 
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.darkGreen,
                fontWeight: FontWeight.bold
              )
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "This action cannot be undone. What would you like to clear?",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text("Clear Salary Amount", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  value: clearSalary,
                  activeColor: AppTheme.limeAccent,
                  checkColor: AppTheme.darkGreen,
                  onChanged: (val) => setState(() => clearSalary = val ?? false),
                ),
                CheckboxListTile(
                  title: Text("Clear All Expenses", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  value: clearExpenses,
                  activeColor: AppTheme.limeAccent,
                  checkColor: AppTheme.darkGreen,
                  onChanged: (val) => setState(() => clearExpenses = val ?? false),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: AppTheme.greyText)),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final repo = await widget.ref.read(walletRepositoryProvider.future);
                    await repo.clearBalance(clearSalary: clearSalary, clearExpenses: clearExpenses);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Balance cleared successfully")));
                    }
                    widget.ref.invalidate(currentWalletStatsProvider);
                    widget.ref.invalidate(recentExpensesProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.destructive,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Clear"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpenseRow extends ConsumerWidget {
  final ExpenseItem expense;

  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.limeAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy • HH:mm').format(expense.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${currency.symbol}${expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.destructive,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.utilities:
        return Icons.bolt_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.health:
        return Icons.favorite_outline;
      case ExpenseCategory.education:
        return Icons.school_outlined;
      case ExpenseCategory.travel:
        return Icons.flight_outlined;
      case ExpenseCategory.other:
        return Icons.category_outlined;
    }
  }
}



class _DetectedTransactionBanner extends StatelessWidget {
  final AsyncValue<List<AutoTransaction>> pendingTransactionsAsync;

  const _DetectedTransactionBanner({required this.pendingTransactionsAsync});

  @override
  Widget build(BuildContext context) {
    return pendingTransactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.limeAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sms_outlined, color: AppTheme.limeAccent, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${transactions.length} New Transactions",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "We've detected new transactions from your SMS.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/sms-review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.limeAccent,
                      foregroundColor: AppTheme.darkGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text("Review", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _QuickSpendingStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final todaySpending = ref.watch(todaySpendingProvider);
    final weekSpending = ref.watch(thisWeekSpendingProvider);
    final monthSpending = ref.watch(thisMonthSpendingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSpendingColumn(
            context,
            'Today',
            todaySpending,
            currency.symbol,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.limeAccent.withOpacity(0.2),
          ),
          _buildSpendingColumn(
            context,
            'This Week',
            weekSpending,
            currency.symbol,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.limeAccent.withOpacity(0.2),
          ),
          _buildSpendingColumn(
            context,
            'This Month',
            monthSpending,
            currency.symbol,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingColumn(
    BuildContext context,
    String label,
    AsyncValue<double> amountAsync,
    String currencySymbol,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.limeAccent.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          amountAsync.when(
            data: (amount) => Text(
              '$currencySymbol${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.limeAccent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            loading: () => Text(
              '$currencySymbol--',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.limeAccent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            error: (_, __) => Text(
              '$currencySymbol 0',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.limeAccent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSubscriptionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final upcomingAsync = ref.watch(upcomingSubscriptionsProvider);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (upcomingAsync.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

      final nearest = upcomingAsync.first;
      final daysLeft = nearest.nextDueDate.difference(DateTime.now()).inDays;

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.repeat_rounded,
                    color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Subscription',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.greyText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${nearest.name} renews in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${nearest.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/subscriptions'),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Error building _UpcomingSubscriptionCard: $e\n$st');
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}

class _LoanDueCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final activeLoans = ref.watch(activeLoansProvider);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (activeLoans.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

      final nearest = activeLoans.first;
      final daysLeft = nearest.nextDueDate.difference(DateTime.now()).inDays;

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.orangeAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan EMI Due',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.greyText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${nearest.name} EMI due in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${nearest.emiAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final repo = ref.read(loanRepositoryProvider);
                    if (repo != null) {
                      repo.recordPayment(nearest, nearest.emiAmount);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Error building _LoanDueCard: $e\n$st');
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}

class _BillScannerCard extends StatelessWidget {
  const _BillScannerCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: GestureDetector(
          onTap: () => context.push('/scanner'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1A1A1A), const Color(0xFF2C2C2E)]
                    : [Colors.white, const Color(0xFFF2F2F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.limeAccent.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.limeAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Snap & Smart-Fill',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'OCR scans your bills automatically',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
