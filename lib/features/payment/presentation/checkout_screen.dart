import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker_pro/core/theme/design_system.dart';
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_plan.dart';
import 'package:expense_tracker_pro/features/payment/data/payment_repository.dart';
import 'package:expense_tracker_pro/features/payment/domain/payment_session.dart';
import 'package:expense_tracker_pro/features/payment/services/upi_service.dart';
import 'package:expense_tracker_pro/features/payment/providers/payment_timer_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedMethod = 'Google Pay';
  bool _isProcessing = false;

  final List<Map<String, String>> paymentMethods = [
    {'name': 'Google Pay', 'icon': 'assets/images/gpay_logo.png'},
    {'name': 'PhonePe', 'icon': 'assets/images/phonepe_logo.png'},
  ];

  Future<void> _handlePayment() async {
    if (_isProcessing) return;
    
    final selectedPlan = ref.read(selectedPlanProvider);
    final user = ref.read(authStateProvider).value;
    
    // For guest payments, we'll use a placeholder or just let sessionId track it.
    // The user will link this payment after signing up.
    final userId = user?.uid ?? 'guest_${const Uuid().v4()}';

    setState(() => _isProcessing = true);

    try {
      final planDetails = _getPlanDetails(selectedPlan);
      final amountStr = planDetails.price.replaceAll('₹', '');
      final amount = int.parse(amountStr);
      final sessionId = const Uuid().v4();
      
      // 1. Create Payment Session in Firestore
      final session = PaymentSession(
        id: sessionId,
        userId: userId,
        planId: selectedPlan,
        amount: amount,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      await ref.read(paymentRepositoryProvider).createSession(session);

      // 2. Start Countdown Timer
      await ref.read(paymentTimerProvider.notifier).startTimer();

      // 3. Launch UPI Intent
      final package = UpiService.getPackageName(selectedMethod);
      final launched = await UpiService.launchUpiIntent(
        amount: amount.toString(),
        transactionId: sessionId,
        appPackage: package,
      );

      if (context.mounted) {
        if (launched) {
          // 4. Navigate to Status Screen to wait for verification
          context.push('/payment-status?sessionId=$sessionId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch UPI app. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final planDetails = _getPlanDetails(selectedPlan);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final timerState = ref.watch(paymentTimerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppTheme.darkGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Section
            const Text(
              'Plan Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.limeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.star_rounded, color: AppTheme.limeAccent, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planDetails.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          planDetails.description,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    planDetails.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment Methods
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...paymentMethods.map((method) {
              final isSelected = selectedMethod == method['name'];
              return GestureDetector(
                onTap: () => setState(() => selectedMethod = method['name']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? (isDark ? AppTheme.limeAccent.withOpacity(0.1) : AppTheme.limeAccent.withOpacity(0.05))
                      : (isDark ? Colors.white.withOpacity(0.02) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen.withOpacity(0.3))
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Radio-style indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.limeAccent : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected 
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.limeAccent,
                                ),
                              ),
                            )
                          : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        method['name']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Simple payment icon
                      Icon(
                        method['name'] == 'Google Pay' ? Icons.payment_rounded : Icons.account_balance_wallet_rounded,
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  planDetails.price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (timerState.isExpired || _isProcessing) ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  child: _isProcessing 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkGreen),
                      )
                    : const Text(
                        'Pay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  _PlanDetails _getPlanDetails(SubscriptionTier plan) {
    switch (plan) {
      case SubscriptionTier.basic:
        return _PlanDetails('Basic Plan', 'Capture 10 bills/mo', '₹149');
      case SubscriptionTier.pro:
        return _PlanDetails('Pro Plan', 'Unlimited AI & Insights', '₹199');
      case SubscriptionTier.free:
      default:
        return _PlanDetails('Free Plan', 'Basic access', '₹0');
    }
  }
}

class _PlanDetails {
  final String name;
  final String description;
  final String price;

  _PlanDetails(this.name, this.description, this.price);
}
