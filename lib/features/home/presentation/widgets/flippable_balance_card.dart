import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../../wallet/data/wallet_repository.dart';
import '../../../auto_tracking/providers/auto_tracking_providers.dart';
import '../../../auto_tracking/domain/auto_transaction.dart';
import '../../../auto_tracking/presentation/detected_transaction_dialog.dart';
import '../../../wallet/providers/wallet_providers.dart';

class FlippableBalanceCard extends StatefulWidget {
  final WalletStats stats;
  final String currencySymbol;
  final VoidCallback onTap;
  final WidgetRef ref;

  const FlippableBalanceCard({
    super.key,
    required this.stats,
    required this.currencySymbol,
    required this.onTap,
    required this.ref,
  });

  @override
  State<FlippableBalanceCard> createState() => _FlippableBalanceCardState();
}

class _FlippableBalanceCardState extends State<FlippableBalanceCard> 
    with SingleTickerProviderStateMixin {
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
    if (_flipController.isDismissed) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingsFormatted = widget.stats.savingsPercentage.toStringAsFixed(0);
    
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= math.pi / 2
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBackSide(context),
                  )
                : _buildFrontSide(context, savingsFormatted),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(BuildContext context, String savingsFormatted) {
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
          
          Text(
            'Remaining Amount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGreen.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),
          
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

  Widget _buildBackSide(BuildContext context) {
    final autoTrackingAsync = widget.ref.watch(pendingTransactionsProvider);
    
    return autoTrackingAsync.when(
      data: (transactions) {
        final totalTracked = transactions.fold<double>(
          0.0,
          (sum, transaction) => sum + (transaction.amount ?? 0.0),
        );
        
        return _buildBackSideContent(context, totalTracked, transactions.length);
      },
      loading: () => _buildBackSideContent(context, 0.0, 0),
      error: (_, __) => _buildBackSideContent(context, 0.0, 0),
    );
  }

  Widget _buildBackSideContent(BuildContext context, double totalTracked, int transactionCount) {
    // Calculate separate credit and debit totals
    final transactionsAsync = widget.ref.watch(pendingTransactionsProvider);
    double credited = 0.0;
    double debited = 0.0;
    
    final now = DateTime.now();
    final firstOfCurrentMonth = DateTime(now.year, now.month, 1);

    transactionsAsync.whenData((transactions) {
      for (var tx in transactions) {
        // Only count transactions from the current calendar month
        if (tx.receivedAt.isAfter(firstOfCurrentMonth) || tx.receivedAt.isAtSameMomentAs(firstOfCurrentMonth)) {
          if (tx.type == TransactionType.credit) {
            credited += tx.amount ?? 0.0;
          } else if (tx.type == TransactionType.debit) {
            debited += tx.amount ?? 0.0;
          }
        }
      }
    });

    return Container(
      width: double.infinity,
      height: 300, // Fixed height to match front card
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkGreen, AppTheme.darkGreen.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SMS TRACKING',
                  style: TextStyle(
                    color: AppTheme.limeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Row(
                children: [
                  _SyncButton(ref: widget.ref),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.nfc,
                    color: AppTheme.limeAccent,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.currencySymbol}${debited.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.limeAccent,
                      ),
                    ),
                    Text(
                      'Sent Payment',
                      style: TextStyle(
                        color: AppTheme.limeAccent.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.limeAccent.withOpacity(0.2)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.currencySymbol}${credited.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Received Payment',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                context, 
                'Sent', 
                Icons.arrow_upward, 
                () => _showTransactionSheet(context, TransactionType.debit, 'Sent Payments'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                context, 
                'Received', 
                Icons.arrow_downward, 
                () => _showTransactionSheet(context, TransactionType.credit, 'Received Payments'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                context, 
                'UPI', 
                Icons.qr_code, 
                () => _showTransactionSheet(context, null, 'UPI Transactions', isUpiOnly: true),
              ),
            ],
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.limeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sms_outlined, size: 12, color: AppTheme.limeAccent),
                    const SizedBox(width: 6),
                    Text(
                      '$transactionCount TRX',
                      style: const TextStyle(
                        color: AppTheme.limeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '****  ****  ${(DateTime.now().year % 100).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: AppTheme.limeAccent.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.limeAccent.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, size: 18, color: AppTheme.limeAccent),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.limeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                    widget.ref.invalidate(currentWalletStatsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Balance cleared successfully")));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showTransactionSheet(BuildContext context, TransactionType? type, String title, {bool isUpiOnly = false}) {
    final transactionsAsync = widget.ref.read(pendingTransactionsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return transactionsAsync.when(
          data: (transactions) {
            final filtered = transactions.where((tx) {
              if (isUpiOnly) {
                final body = tx.originalSmsBody.toLowerCase();
                return body.contains('upi') || body.contains('vpa');
              }
              return tx.type == type;
            }).toList();

            // Sort by date descending (newest first)
            filtered.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: math.min(MediaQuery.of(context).size.height * 0.7, 500),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.darkGreen,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : AppTheme.greyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: isDark ? Colors.white38 : AppTheme.greyText),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.limeAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                type == TransactionType.credit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: AppTheme.limeAccent,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx.merchantName ?? 'Unknown Merchant',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, HH:mm').format(tx.receivedAt),
                              style: TextStyle(color: isDark ? Colors.white38 : AppTheme.greyText, fontSize: 12),
                            ),
                            trailing: Text(
                              '${widget.currencySymbol}${tx.amount?.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.darkGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => DetectedTransactionDialog(transaction: tx),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }
  Widget _buildLoadingBackSide() {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkGreen, AppTheme.darkGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.limeAccent),
        ),
      ),
    );
  }
}

class _SyncButton extends StatefulWidget {
  final WidgetRef ref;
  const _SyncButton({required this.ref});

  @override
  State<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<_SyncButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const SizedBox(
          width: 24, 
          height: 24, 
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.limeAccent)
        )
      : IconButton(
          icon: const Icon(Icons.sync, color: AppTheme.limeAccent, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              await widget.ref.read(autoTrackingControllerProvider).syncManual();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SMS sync complete!')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync failed: ${e.toString()}')),
                );
              }
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
        );
  }
}
