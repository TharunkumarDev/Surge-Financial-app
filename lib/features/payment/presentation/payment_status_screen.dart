import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:expense_tracker_pro/core/theme/design_system.dart';
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';
import 'package:expense_tracker_pro/features/subscription/providers/subscription_providers.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_plan.dart';
import 'package:expense_tracker_pro/features/payment/data/payment_repository.dart';
import 'package:expense_tracker_pro/features/payment/domain/payment_session.dart';
import 'package:expense_tracker_pro/features/payment/providers/payment_timer_provider.dart';

class PaymentStatusScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const PaymentStatusScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends ConsumerState<PaymentStatusScreen> {
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    ref.read(paymentTimerProvider.notifier).restoreTimer();
  }

  Future<void> _handleSuccess(PaymentSession session) async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    ref.read(paymentTimerProvider.notifier).stopTimer();

    try {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        await ref.read(subscriptionRepositoryProvider).updateSubscription(
          user.uid,
          session.planId,
        );
      }
    } catch (e) {
      debugPrint('Error unlocking subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionAsync = ref.watch(paymentSessionStreamProvider(widget.sessionId));
    final timerState = ref.watch(paymentTimerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(child: Text('Session not found'));
          }

          final status = session.status;
          final isExpired = timerState.isExpired || status == PaymentStatus.expired;

          if (status == PaymentStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _handleSuccess(session));
          }

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/surge_logo_black.png',
                  height: 40,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusIcon(status, isExpired, isDark),
                        const SizedBox(height: 32),
                        Text(
                          _getStatusTitle(status, isExpired),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.grey.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.limeAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.star_rounded, color: AppTheme.limeAccent, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getPlanName(session.planId),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Active Subscription',
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (status == PaymentStatus.pending && !isExpired)
                          Text(
                            'Session ends in ${timerState.formattedTime}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (status == PaymentStatus.success) {
                              context.push('/signup?sessionId=${widget.sessionId}');
                            } else if (status == PaymentStatus.failed || isExpired) {
                              context.pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            status == PaymentStatus.success 
                              ? 'Complete Signup' 
                              : (status == PaymentStatus.failed || isExpired ? 'Back to Checkout' : 'Please wait...'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.go('/welcome'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Return to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.limeAccent)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status, bool isExpired, bool isDark) {
    IconData icon;
    Color color;
    
    if (status == PaymentStatus.success) {
      icon = Icons.check;
      color = AppTheme.limeAccent;
    } else if (status == PaymentStatus.failed || isExpired) {
      icon = Icons.close;
      color = Colors.redAccent;
    } else {
      return const SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: AppTheme.limeAccent,
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            icon,
            color: (status == PaymentStatus.success && isDark) ? AppTheme.darkGreen : Colors.white,
            size: 32,
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  String _getStatusTitle(PaymentStatus status, bool isExpired) {
    if (isExpired && status == PaymentStatus.pending) return 'SESSION EXPIRED';
    switch (status) {
      case PaymentStatus.success: return 'PAYMENT SUCCESS';
      case PaymentStatus.failed: return 'PAYMENT FAILED';
      case PaymentStatus.pending: return 'VERIFYING PAYMENT';
      case PaymentStatus.expired: return 'SESSION EXPIRED';
    }
  }

  String _getStatusSubtitle(PaymentStatus status, bool isExpired) {
    if (isExpired && status == PaymentStatus.pending) {
      return 'The payment window has closed.\nPlease try again.';
    }
    switch (status) {
      case PaymentStatus.success:
        return 'Your subscription has been activated.\nYou can now enjoy all premium features.';
      case PaymentStatus.failed:
        return 'Something went wrong.\nPlease try again.';
      case PaymentStatus.pending:
        return 'Waiting for bank confirmation...';
      case PaymentStatus.expired:
        return 'The session has expired.';
    }
  }

  String _getPlanName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic: return 'Basic Plan';
      case SubscriptionTier.pro: return 'Pro Plan';
      case SubscriptionTier.free: return 'Free Plan';
    }
  }
}
