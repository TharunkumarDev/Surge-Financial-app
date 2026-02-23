import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../providers/security_providers.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityStateProvider);
    final controller = ref.read(securityStateProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Security",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkGreen,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppTheme.darkGreen),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Illustration (Optional, maybe just spacing for now)
          const SizedBox(height: 10),
          
          _SectionHeader("App Security"),
          
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text(
                    "Enable App Lock",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.darkGreen,
                    ),
                  ),
                  subtitle: Text(
                    "Require authentication to open app",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : AppTheme.greyText,
                      fontSize: 13,
                    ),
                  ),
                  value: securityState.isAppLockEnabled,
                  activeColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  activeTrackColor: isDark ? AppTheme.limeAccent.withOpacity(0.5) : AppTheme.limeAccent,
                  onChanged: (value) => controller.enableAppLock(value),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                  ),
                ),
                
                // Animated Biometric Option
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: securityState.isAppLockEnabled
                      ? Column(
                          children: [
                            Divider(
                              height: 1, 
                              indent: 20, 
                              endIndent: 20, 
                              color: isDark ? Colors.white10 : Colors.grey.shade100,
                            ),
                            SwitchListTile.adaptive(
                              title: Text(
                                "Biometric Authentication",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.darkGreen,
                                ),
                              ),
                              subtitle: Text(
                                "Use Face ID or Fingerprint",
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : AppTheme.greyText,
                                  fontSize: 13,
                                ),
                              ),
                              value: securityState.isBiometricEnabled,
                              activeColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                              activeTrackColor: isDark ? AppTheme.limeAccent.withOpacity(0.5) : AppTheme.limeAccent,
                              onChanged: (value) => controller.enableBiometric(value),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Enhanced Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined, 
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How it works",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Surge uses your device's native security (Pattern, PIN, or Biometrics) to verify your identity. The app automatically locks when minimized.",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _SectionHeader("Device Settings"),
          
          // Change PIN / Device Settings Link
           Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.phonelink_lock_rounded, 
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                  size: 20
                ),
              ),
              title: Text(
                "System Security Settings",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                ),
              ),
              subtitle: Text(
                "Manage your device PIN/Pattern",
                style: TextStyle(
                   color: isDark ? Colors.white60 : AppTheme.greyText,
                   fontSize: 12
                ),
              ),
              trailing: Icon(Icons.open_in_new_rounded, size: 16, color: isDark ? Colors.white30 : AppTheme.greyText),
              onTap: () {
                // We typically can't open the exact settings page cross-platform easily without a plugin like 'app_settings'
                // For now, showcase a snackbar or helpful dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Please open your Device Settings to change your PIN/Pattern."),
                    backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.darkGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white54 : AppTheme.greyText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
