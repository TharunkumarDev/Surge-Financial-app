import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/loan_model.dart';
import '../../providers/loan_providers.dart';
import '../../../../core/services/reminder_service.dart';

class LoanCard extends ConsumerWidget {
  final LoanModel loan;

  const LoanCard({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = loan.totalAmount > 0 
        ? (loan.totalAmount - loan.remainingAmount) / loan.totalAmount 
        : 0.0;
    
    final daysUntil = loan.nextDueDate.difference(DateTime.now()).inDays;
    final isCompleted = loan.status == LoanStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.account_balance_wallet_rounded,
                          color: isCompleted 
                            ? Colors.green 
                            : (isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.name,
                              style: AppTheme.heading3.copyWith(
                                color: isDark ? Colors.white : AppTheme.darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCompleted ? 'Loan Fully Paid' : 'Next Payment: ${DateFormat('MMM dd').format(loan.nextDueDate)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${loan.emiAmount.toStringAsFixed(0)}',
                                style: AppTheme.heading3.copyWith(
                                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showDeleteConfirmation(context, ref),
                              ),
                            ],
                          ),
                          Text(
                            'per month',
                            style: AppTheme.labelSmall.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Repayment Progress',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.4),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 8,
                        width: MediaQuery.of(context).size.width * progress * 0.7, // Approx
                        decoration: BoxDecoration(
                          gradient: AppTheme.premiumGradient,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.limeAccent.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(loan.totalAmount - loan.remainingAmount).toStringAsFixed(0)} Paid',
                        style: AppTheme.labelSmall,
                      ),
                      Text(
                        '₹${loan.remainingAmount.toStringAsFixed(0)} Remaining',
                        style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              InkWell(
                onTap: () => _payEMI(ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.05),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_task_rounded,
                          size: 18,
                          color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Record Monthly Payment',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _payEMI(WidgetRef ref) {
    final repo = ref.read(loanRepositoryProvider);
    if (repo != null) {
      repo.recordPayment(loan, loan.emiAmount);
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1C1C1E) 
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Loan?', style: AppTheme.heading3),
        content: Text(
          'This will permanently remove "${loan.name}" and cancel all its reminders.',
          style: AppTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLoan(ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteLoan(WidgetRef ref) async {
    final repo = ref.read(loanRepositoryProvider);
    if (repo != null) {
      // 1. Cancel Reminders
      await ReminderService().cancelReminders(loan.id);
      // 2. Delete from Repository
      await repo.deleteLoan(loan.id);
    }
  }
}
