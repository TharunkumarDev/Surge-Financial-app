import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/subscription_model.dart';
import '../../providers/subscription_tracker_providers.dart';
import '../../../../core/services/reminder_service.dart';

class SubscriptionCard extends ConsumerWidget {
  final SubscriptionModel subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysUntil = subscription.nextDueDate.difference(DateTime.now()).inDays;
    
    Color statusColor;
    if (daysUntil < 0) {
      statusColor = Colors.redAccent;
    } else if (daysUntil <= 3) {
      statusColor = Colors.orangeAccent;
    } else {
      statusColor = isDark ? AppTheme.limeAccent : AppTheme.darkGreen;
    }

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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getIcon(subscription.name),
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
                          subscription.name,
                          style: AppTheme.heading3.copyWith(
                            color: isDark ? Colors.white : AppTheme.darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Next Bill: ${DateFormat('MMM dd').format(subscription.nextDueDate)}',
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
                            '₹${subscription.amount.toStringAsFixed(0)}',
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
                        subscription.billingCycle.name.toLowerCase(),
                        style: AppTheme.labelSmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.05),
                border: Border(
                  top: BorderSide(
                    color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        daysUntil < 0 
                          ? 'Overdue' 
                          : daysUntil == 0 
                            ? 'Due Today' 
                            : '$daysUntil days left',
                        style: AppTheme.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _markAsPaid(ref),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mark Paid',
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
          ],
        ),
      ),
    );
  }

  void _markAsPaid(WidgetRef ref) {
    final repo = ref.read(subscriptionTrackerRepositoryProvider);
    if (repo != null) {
      repo.markAsPaid(subscription);
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
        title: Text('Delete Subscription?', style: AppTheme.heading3),
        content: Text(
          'This will permanently remove "${subscription.name}" and cancel all its reminders.',
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
              _deleteSubscription(ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteSubscription(WidgetRef ref) async {
    final repo = ref.read(subscriptionTrackerRepositoryProvider);
    if (repo != null) {
      // 1. Cancel Reminders
      await ReminderService().cancelReminders(subscription.id);
      // 2. Delete from Repository
      await repo.deleteSubscription(subscription.id);
    }
  }

  IconData _getIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('netflix')) return Icons.play_circle_fill_rounded;
    if (n.contains('spotify')) return Icons.music_note_rounded;
    if (n.contains('youtube')) return Icons.video_collection_rounded;
    if (n.contains('amazon')) return Icons.shopping_bag_rounded;
    if (n.contains('icloud') || n.contains('apple')) return Icons.cloud_rounded;
    return Icons.repeat_rounded;
  }
}
