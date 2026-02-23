import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/subscription_plan.dart';
import '../../../../core/theme/design_system.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/subscription_providers.dart';

class UpgradeDialog extends ConsumerWidget {
  final String featureName;
  final SubscriptionTier minimumTier;

  const UpgradeDialog({
    super.key,
    required this.featureName,
    required this.minimumTier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Upgrade Required',
        style: TextStyle(
          color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To access "$featureName", you need to upgrade to ${minimumTier.displayName} plan.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildPlanCard(context, SubscriptionTier.basic),
          const SizedBox(height: 12),
          _buildPlanCard(context, SubscriptionTier.pro),
        ],
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            // Mock payment flow
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: AppTheme.limeAccent),
              ),
            );

            await Future.delayed(const Duration(milliseconds: 1500)); // Simulate payment processing

            try {
              final user = ref.read(authStateProvider).value;
              if (user != null) {
                // Get current subscription tier
                final currentSubscription = ref.read(currentSubscriptionProvider).value;
                final oldTier = currentSubscription?.tier ?? SubscriptionTier.free;
                
                await ref.read(subscriptionRepositoryProvider).updateSubscription(
                  user.uid, 
                  minimumTier,
                  oldTier: oldTier,
                );
              }
              
              if (context.mounted) {
                Navigator.pop(context); // Close loading
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Upgrade Successful! Enjoy your new features.'),
                    backgroundColor: AppTheme.darkGreen,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Upgrade failed: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
            foregroundColor: isDark ? AppTheme.darkGreen : AppTheme.limeAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionTier tier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRecommended = tier == minimumTier;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended 
            ? (isDark ? AppTheme.limeAccent.withOpacity(0.1) : AppTheme.limeAccent.withOpacity(0.2))
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended 
              ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
              : (isDark ? Colors.white10 : Colors.grey.shade200),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getPlanFeatures(tier),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Text(
            '₹${tier.priceInRupees}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanFeatures(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return 'Add expenses • 10 bills/month';
      case SubscriptionTier.pro:
        return 'Unlimited • AI insights';
      case SubscriptionTier.free:
        return 'View only';
    }
  }
}
