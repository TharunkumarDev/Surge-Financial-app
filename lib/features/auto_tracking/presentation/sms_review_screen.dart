import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_system.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
import '../../auto_tracking/providers/auto_tracking_providers.dart';
import '../../auto_tracking/presentation/detected_transaction_dialog.dart';
import '../../../core/providers/currency_provider.dart';

class SmsReviewScreen extends ConsumerWidget {
  const SmsReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(pendingTransactionsProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Review Transactions",
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          // Sort items locally to ensure date-wise order (newest first)
          final sortedList = [...transactions];
          sortedList.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

          if (sortedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppTheme.limeAccent.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "All caught up!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppTheme.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No new SMS transactions to review.",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final tx = sortedList[index];
              final isCredit = tx.type == TransactionType.credit;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx.merchantName ?? "Unknown Merchant",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.darkGreen,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy • HH:mm').format(tx.receivedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppTheme.greyText,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${currency.symbol}${tx.amount?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCredit ? "Received Payment" : "Sent Payment",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: (isCredit ? Colors.green : Colors.red).withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => DetectedTransactionDialog(transaction: tx),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
