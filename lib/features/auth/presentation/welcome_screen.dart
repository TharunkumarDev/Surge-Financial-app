import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.limeAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Surge Logo - Top Left and Subtle
              
              const Spacer(),
              
              // Main Heading
              Text(
                'Surge',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGreen,
                  height: 1.1,
                  letterSpacing: -2,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Track Your Spending\nEffortlessly',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGreen,
                  height: 1.2,
                  letterSpacing: -1,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Subtitle
              Text(
                'Manage your finances easily using our\nintuitive and user-friendly interface and set\nfinancial goals and monitor your progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: AppTheme.darkGreen.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/pricing');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkGreen,
                    foregroundColor: AppTheme.limeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: AppTheme.limeAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.darkGreen.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: AppTheme.darkGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
