import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/subscription_model.dart';
import '../../providers/subscription_tracker_providers.dart';
import '../widgets/subscription_card.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          'Subscriptions',
          style: AppTheme.heading2.copyWith(
            color: isDark ? Colors.white : AppTheme.darkGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _buildEmptyState(context, isDark);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              return SubscriptionCard(subscription: subscriptions[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.premiumGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.limeAccent.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/add-subscription'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: Icon(Icons.add_rounded, color: AppTheme.darkGreen),
            label: Text(
              'Add Subscription',
              style: TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.repeat_on_rounded,
                size: 64,
                color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Recurring Bills',
              style: AppTheme.heading2.copyWith(
                color: isDark ? Colors.white : AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Track your Netflix, Spotify, and other monthly bills. Get notified before they are due and never miss a payment.',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(
                color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
