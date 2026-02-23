import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/finance_intent.dart';

class QuickSuggestionChip extends StatelessWidget {
  final QuickSuggestion suggestion;
  final VoidCallback onTap;
  final bool isPro;
  
  const QuickSuggestionChip({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.isPro = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = suggestion.requiresPro && !isPro;
    
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? AppTheme.limeAccent.withOpacity(0.3)
                : AppTheme.darkGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Icon(
                Icons.lock_outline,
                size: 14,
                color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              suggestion.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLocked
                    ? (isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5))
                    : (isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
              ),
            ),
            if (suggestion.requiresPro) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PRO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
