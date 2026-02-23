import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../providers/security_providers.dart';

class SecuritySetupScreen extends ConsumerWidget {
  const SecuritySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // Animated Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    size: 80,
                    color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2000.ms, curve: Curves.easeInOut)
                .boxShadow(
                    begin: BoxShadow(color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1), blurRadius: 20, spreadRadius: 0),
                    end: BoxShadow(color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                  ),
              ),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                "Secure Your Account",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().moveY(begin: 20, end: 0, delay: 200.ms),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                "Enable biometric authentication to protect your financial data with bank-grade security.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.greyText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              
              const Spacer(flex: 3),
              
              // Primary Action Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Enable App Lock
                     await ref.read(securityStateProvider.notifier).enableAppLock(true);
                     await ref.read(securityStateProvider.notifier).enableBiometric(true);
                     if (context.mounted) {
                       context.go('/home');
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.limeAccent,
                    foregroundColor: AppTheme.darkGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Enable Face ID / Touch ID",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 16),
              
              // Secondary Action
              TextButton(
                onPressed: () {
                   context.go('/home');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Not Now",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppTheme.greyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
