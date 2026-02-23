import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/subscription_plan.dart';
import '../../providers/subscription_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class ModernPaywallDialog extends StatefulWidget {
  const ModernPaywallDialog({super.key});

  @override
  State<ModernPaywallDialog> createState() => _ModernPaywallDialogState();
}

class _ModernPaywallDialogState extends State<ModernPaywallDialog> {
  int _selectedPlanIndex = 0;
// _freeTrialEnabled removed

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Pro Plan',
      'price': '₹199',
      'weekly': '₹50/week',
      'badge': 'BEST PLAN',
      'tier': SubscriptionTier.pro,
    },
    {
      'title': 'Basic Plan',
      'price': '₹149',
      'weekly': '₹37/week',
      'tier': SubscriptionTier.basic,
    },
    {
      'title': 'Free Plan',
      'price': '₹0',
      'weekly': '₹0/week',
      'tier': SubscriptionTier.free,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A1F0D) : Colors.white; // Very dark green for dark mode
    final textColor = isDark ? Colors.white : AppTheme.darkGreen;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: backgroundColor,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textColor.withOpacity(1.0)),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Choose your plan",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Icon(Icons.star, color: Color(0xFFFFD700), size: 28),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Testimonial
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Unlock smart expense tracking, insights, and reports tailored for you",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true, textColor),
                        _buildDot(false, textColor),
                        _buildDot(false, textColor),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Plan Cards
                    ...List.generate(_plans.length, (index) => _buildPlanCard(index, textColor)),
                    const SizedBox(height: 24),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom Action
            Consumer(builder: (context, ref, _) {
              return SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.limeAccent,
                    foregroundColor: AppTheme.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active, Color baseColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? baseColor : baseColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPlanCard(int index, Color textColor) {
    bool isSelected = _selectedPlanIndex == index;
    final plan = _plans[index];
    final hasBadge = plan.containsKey('badge');

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.limeAccent.withOpacity(0.1) : textColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.limeAccent : textColor.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['title'],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              plan['price'],
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (plan.containsKey('oldPrice')) ...[
                              const SizedBox(width: 8),
                              Text(
                                plan['oldPrice'],
                                style: TextStyle(
                                  color: textColor.withOpacity(0.4),
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    plan['weekly'],
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (hasBadge)
              Positioned(
                top: -12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.limeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan['badge'] ?? "",
                      style: const TextStyle(
                        color: AppTheme.darkGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final selectedPlan = _plans[_selectedPlanIndex];
    final tier = selectedPlan['tier'] as SubscriptionTier;

    // Set the selected plan in the global provider so CheckoutScreen knows which one to show
    ref.read(selectedPlanProvider.notifier).state = tier;

    if (tier != SubscriptionTier.free) {
      // Redirect to Checkout Page for paid plans
      if (context.mounted) {
        Navigator.pop(context); // Close the paywall dialog first
        context.push('/checkout');
      }
      return;
    }

    // Existing mock logic for Free Plan (or if tier is Free)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.limeAccent)),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final currentSubscription = ref.read(currentSubscriptionProvider).value;
        final oldTier = currentSubscription?.tier ?? SubscriptionTier.free;
        
        await ref.read(subscriptionRepositoryProvider).updateSubscription(
          user.uid, 
          tier,
          oldTier: oldTier,
        );
      }
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close paywall
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan Updated to ${tier.displayName} Successfully!'),
            backgroundColor: AppTheme.darkGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }
}
