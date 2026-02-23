import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../auth/providers/auth_providers.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  SubscriptionTier selectedPlan = SubscriptionTier.basic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide default back button too if needed
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Text(
                      'Go Premium',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isDark ? Colors.white : AppTheme.darkGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock all features and take control\nof your personal finances',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Refined Illustration Matching Reference
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.limeAccent.withOpacity(0.05) : AppTheme.limeAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            size: 60,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Plan Tiles (Vertical List)
                    _buildPlanTile(
                      context: context,
                      title: 'Free',
                      price: '₹0',
                      period: '/forever',
                      isSelected: selectedPlan == SubscriptionTier.free,
                      onTap: () => setState(() => selectedPlan = SubscriptionTier.free),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildPlanTile(
                      context: context,
                      title: 'Basic',
                      price: '₹149',
                      period: '/mo',
                      isSelected: selectedPlan == SubscriptionTier.basic,
                      onTap: () => setState(() => selectedPlan = SubscriptionTier.basic),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildPlanTile(
                      context: context,
                      title: 'Pro',
                      price: '₹199',
                      period: '/mo',
                      isSelected: selectedPlan == SubscriptionTier.pro,
                      onTap: () => setState(() => selectedPlan = SubscriptionTier.pro),
                      tag: 'Best Value',
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(selectedPlanProvider.notifier).state = selectedPlan;
                        if (selectedPlan == SubscriptionTier.free) {
                          context.push('/signup');
                        } else {
                          context.push('/checkout');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                        foregroundColor: isDark ? AppTheme.darkGreen : AppTheme.limeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Pill shape
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recurring billing, cancel anytime.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
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

  Widget _buildPlanTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    required String price,
    required String period,
    required bool isSelected,
    required VoidCallback onTap,
    String? tag,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Improved colors matching reference image
    final backgroundColor = isSelected 
        ? (isDark ? AppTheme.darkGreen.withOpacity(0.1) : Colors.white)
        : (isDark ? Colors.transparent : Colors.white);
        
    final borderColor = isSelected 
        ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
        : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200);
    
    // Icon and background colors for the selection indicator
    final indicatorBgColor = isSelected 
        ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
        : Colors.transparent;
    final indicatorBorderColor = isSelected 
        ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
        : (isDark ? Colors.white38 : Colors.grey.shade300);
    final checkColor = isDark ? AppTheme.darkGreen : Colors.white;
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected && !isDark ? [
                BoxShadow(
                  color: AppTheme.darkGreen.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                // Selection Indicator (Dark with checkmark when selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorBgColor,
                    border: Border.all(
                      color: indicatorBorderColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                    ? Icon(Icons.check, size: 14, color: checkColor)
                    : null,
                ),
                
                const SizedBox(width: 20),
                
                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.darkGreen,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tag Matching "Best Value" Style
          if (tag != null)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.limeAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
