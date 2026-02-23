import 'package:flutter/material.dart';
import '../../../subscription/domain/subscription_plan.dart';
import '../../../../core/theme/design_system.dart';

/// Dialog shown to Free users when they attempt to use a premium feature
class UpgradeDialog extends StatelessWidget {
  final String featureName;
  final String featureDescription;
  
  const UpgradeDialog({
    Key? key,
    required this.featureName,
    required this.featureDescription,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: Colors.amber.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Upgrade Required',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$featureName is a premium feature.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            featureDescription,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Available on Basic and Pro plans',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.amber.shade100 : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Maybe Later',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
  
  /// Show the upgrade dialog
  static Future<void> show(
    BuildContext context, {
    required String featureName,
    required String featureDescription,
  }) {
    return showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        featureName: featureName,
        featureDescription: featureDescription,
      ),
    );
  }
}
