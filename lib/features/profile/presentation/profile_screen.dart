import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/isar_provider.dart';
import '../domain/user_model.dart';
import '../data/user_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auto_tracking/providers/auto_tracking_providers.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../subscription/domain/feature_entitlement.dart';
import '../../auto_tracking/presentation/sms_permission_dialog.dart';
import '../../auto_tracking/data/sms_service.dart';
import '../../auto_tracking/data/auto_tracking_repository.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../../expense/providers/expense_providers.dart';
import '../../pdf_export/providers/pdf_export_providers.dart';
import '../../subscription/presentation/widgets/upgrade_dialog.dart' as sub_ui;
import '../../pdf_export/presentation/widgets/upgrade_dialog.dart' as pdf_ui;
import '../../subscription/presentation/widgets/modern_paywall_dialog.dart';
import '../../subscription/presentation/widgets/pro_success_dialog.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/data/expense_repository.dart';
import '../../../core/services/sync_coordinator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.white : AppTheme.darkGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: userAsync.when(
        data: (user) => _buildProfileContent(context, ref, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading profile")),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 120, AppSpacing.lg, 100),
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.premiumGradient,
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: AppTheme.limeAccent,
                        child: Icon(
                          Icons.person_rounded, 
                          size: 48, 
                          color: AppTheme.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user?.username ?? "User",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? "user@example.com",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : AppTheme.greyText,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(context, ref, user),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text("Edit Profile"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  side: BorderSide(color: isDark ? AppTheme.limeAccent.withOpacity(0.5) : AppTheme.darkGreen.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        _SectionHeader("Account"),
        _SettingsGroup(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final tier = ref.watch(currentSubscriptionTierProvider);
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return _SettingsTile(
                  icon: Icons.stars_rounded,
                  title: "${tier.displayName} Plan",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: tier == SubscriptionTier.pro ? AppTheme.premiumGradient : null,
                      color: tier != SubscriptionTier.pro ? _getTierColor(tier, isDark).withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: tier != SubscriptionTier.pro ? Border.all(color: _getTierColor(tier, isDark).withOpacity(0.3), width: 1) : null,
                    ),
                    child: Text(
                      tier.displayName.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 10,
                        color: tier == SubscriptionTier.pro ? AppTheme.darkGreen : _getTierColor(tier, isDark),
                      ),
                    ),
                  ), 
                  onTap: () {
                    if (tier != SubscriptionTier.pro) {
                      showDialog(
                        context: context,
                        useRootNavigator: true,
                        builder: (context) => const ModernPaywallDialog(),
                      );
                    } else {
                      showDialog(
                        context: context,
                        useRootNavigator: true,
                        builder: (context) => const ProUserSuccessDialog(),
                      );
                    }
                  },
                );
              }
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        _SectionHeader("Preferences"),
        _SettingsGroup(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(themeModeProvider);
                String themeName = "System Default";
                if (themeMode == ThemeMode.light) themeName = "Light Mode";
                if (themeMode == ThemeMode.dark) themeName = "Dark Mode";

                return _SettingsTile(
                  icon: Icons.palette_rounded,
                  title: "Theme",
                  subtitle: themeName,
                  onTap: () => _showThemeSelection(context, ref),
                );
              }
            ),
            _SettingsTile(
              icon: Icons.security_rounded,
              title: "Security",
              subtitle: "App Lock & Biometrics",
              onTap: () => context.push('/security-settings'),
            ),
            _SettingsTile(
              icon: Icons.currency_rupee_rounded,
              title: "Currency",
              subtitle: ref.watch(currencyProvider).code,
              onTap: () => _showCurrencySelection(context, ref),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        _SectionHeader("Data"),
        _SettingsGroup(
          children: [
            _PdfExportTile(),
          ],
        ),
        
        const SizedBox(height: 24),
        _SectionHeader("Automation"),
        _SyncTransactionsButton(),
        
        const SizedBox(height: 24),
        _SectionHeader("Support"),
        _SettingsGroup(
          children: [
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: "Help & Support",
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: "About",
              subtitle: "Version 1.0.0",
              onTap: () {},
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Prominent Logout Button
        Center(
          child: SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                // Confirm Dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: isDark ? Colors.white : AppTheme.darkGreen),
                    ),
                    content: Text(
                      'Are you sure you want to sign out?',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
    
                if (shouldLogout == true) {
                  final authRepo = await ref.read(authRepositoryProvider.future);
                  await authRepo.signOut();
                }
              },
              icon: Icon(Icons.logout_rounded, color: Colors.red[400]),
              label: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User? user) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 24),
              
              // Custom Input Fields
              _buildDialogTextField(
                context: context,
                controller: usernameController,
                label: 'Username',
                icon: Icons.person_rounded,
                isDark: isDark,
              ),
              
              const SizedBox(height: 20),
              
              _buildDialogTextField(
                context: context,
                controller: emailController,
                label: 'Email',
                icon: Icons.email_rounded,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final username = usernameController.text.trim();
                      final email = emailController.text.trim();
                      
                      if (username.isNotEmpty && email.isNotEmpty) {
                        final repo = await ref.read(userRepositoryProvider.future);
                        await repo.updateUser(username, email);
                        ref.invalidate(currentUserProvider);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                      foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.darkGreen,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Color _getTierColor(SubscriptionTier tier, bool isDark) {
    switch (tier) {
      case SubscriptionTier.free:
        return AppTheme.greyText;
      case SubscriptionTier.basic:
        return Colors.blue;
      case SubscriptionTier.pro:
        return isDark ? AppTheme.limeAccent : AppTheme.darkGreen;
    }
  }

  void _showCurrencySelection(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Currency",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : AppTheme.darkGreen,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
            Expanded(
              child: ListView.builder(
                itemCount: kCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = kCurrencies[index];
                  final isSelected = ref.read(currencyProvider).code == currency.code;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                        ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
                        : (isDark ? Colors.white.withOpacity(0.05) : AppTheme.backgroundLight),
                      child: Text(
                        currency.symbol,
                        style: TextStyle(
                          color: isSelected 
                            ? (isDark ? AppTheme.darkGreen : Colors.white) 
                            : (isDark ? Colors.white : AppTheme.darkGreen),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      currency.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isDark ? Colors.white : AppTheme.darkGreen,
                      ),
                    ),
                    subtitle: Text(
                      currency.code,
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                    ),
                    trailing: isSelected 
                      ? Icon(Icons.check, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen) 
                      : null,
                    onTap: () {
                      ref.read(currencyProvider.notifier).setCurrency(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelection(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Theme",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text("System Default"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text("Light Mode"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppTheme.greyText,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppTheme.limeAccent : AppTheme.darkGreen;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppTheme.darkGreen,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle!,
        style: TextStyle(color: isDark ? Colors.white54 : AppTheme.greyText),
      ) : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right_rounded, 
        color: isDark ? Colors.white24 : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

/// User-Initiated SMS Sync Button (Play Store Compliant)
class _SyncTransactionsButton extends ConsumerStatefulWidget {
  const _SyncTransactionsButton();

  @override
  ConsumerState<_SyncTransactionsButton> createState() => _SyncTransactionsButtonState();
}

class _SyncTransactionsButtonState extends ConsumerState<_SyncTransactionsButton> {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  @override
  Widget build(BuildContext context) {
    // Hide on iOS - Android-only feature
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sync_rounded, 
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen, 
                  size: 24
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transaction Sync",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Scan SMS for bank transactions",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_lastSyncTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Text(
                "Last synced: ${_formatSyncTime(_lastSyncTime!)}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (!_isSyncing)
                    BoxShadow(
                      color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncTransactions,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(_isSyncing ? "Syncing..." : "Sync Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncTransactions() async {
    final entitlement = ref.read(entitlementServiceProvider);
    final tier = ref.read(currentSubscriptionTierProvider);

    if (!entitlement.hasAccess(AppFeature.transactionSync, tier)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => sub_ui.UpgradeDialog(
            featureName: "Transaction Sync",
            minimumTier: entitlement.getMinimumTierForFeature(AppFeature.transactionSync),
          ),
        );
      }
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    setState(() => _isSyncing = true);

    try {
      final smsService = ref.read(smsServiceProvider);
      final hasPermission = await smsService.hasSmsPermission();

      if (!hasPermission && mounted) {
        final shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("SMS Permission Required"),
            content: const Text(
              "Surge needs SMS permission to scan your inbox for bank transaction alerts.\n\n"
              "This is a one-time sync and will NOT:\n"
              "• Run in background\n"
              "• Auto-read new messages\n"
              "• Access personal messages\n\n"
              "Only bank transaction alerts will be detected."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                  foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                ),
                child: const Text("Grant Permission"),
              ),
            ],
          ),
        );

        if (shouldRequest != true) {
          setState(() => _isSyncing = false);
          return;
        }

        final granted = await smsService.hasSmsPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("SMS permission is required to sync transactions"),
              ),
            );
          }
          setState(() => _isSyncing = false);
          return;
        }
      }

      final transactions = await smsService.syncTransactionsFromInbox();
      
      if (mounted) {
        setState(() {
          _lastSyncTime = DateTime.now();
          _isSyncing = false;
        });

        final autoTrackingRepo = await ref.read(autoTrackingRepositoryProvider.future);
        for (var transaction in transactions) {
          await autoTrackingRepo.saveTransaction(transaction);
        }

        ref.invalidate(currentWalletStatsProvider);
        ref.invalidate(recentExpensesProvider);
        ref.invalidate(pendingTransactionsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactions.isEmpty
                  ? "No new transactions found"
                  : "Found ${transactions.length} transaction(s)",
            ),
            backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sync failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return "just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}

/// PDF Export Tile with plan-based access control
class _PdfExportTile extends ConsumerWidget {
  const _PdfExportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(currentSubscriptionTierProvider);
    final entitlement = ref.watch(entitlementServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canExport = entitlement.canExportPdf(tier);

    return _SettingsTile(
      icon: Icons.picture_as_pdf,
      title: "Export as PDF",
      subtitle: canExport 
        ? "Download your expense history as PDF"
        : "Upgrade to Basic or Pro to export PDFs",
      trailing: canExport 
        ? null 
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: Colors.amber.withOpacity(0.5)) : null,
            ),
            child: Text(
              'PRO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.amber : Colors.amber.shade900,
              ),
            ),
          ),
      onTap: () => _handleExportTap(context, ref, canExport),
    );
  }

  Future<void> _handleExportTap(
    BuildContext context,
    WidgetRef ref,
    bool canExport,
  ) async {
    if (!canExport) {
      // Show upgrade dialog for Free users
      await pdf_ui.UpgradeDialog.show(
        context,
        featureName: 'PDF Export',
        featureDescription: 'Export your expense history as a professional PDF report with date range filtering and category breakdowns.',
      );
      return;
    }

    // Show date range picker
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? ColorScheme.dark(
                  primary: AppTheme.limeAccent,
                  onPrimary: AppTheme.darkGreen,
                  surface: AppTheme.surfaceDark,
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: AppTheme.darkGreen,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppTheme.darkGreen,
                ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange == null) return;

    // Show loading indicator
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Generating PDF...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      // Fetch all expenses
      final allExpensesAsync = ref.read(allExpensesProvider);
      final allExpenses = allExpensesAsync.value ?? [];
      
      // Filter by date range
      final expenses = allExpenses.where((expense) {
        return expense.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
               expense.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();

      if (expenses.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No expenses found in the selected date range'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Generate and share PDF
      final pdfService = ref.read(pdfExportServiceProvider);
      await pdfService.exportAndShare(
        expenses: expenses,
        startDate: dateRange.start,
        endDate: dateRange.end,
        title: 'Expense Report',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('PDF exported successfully (${expenses.length} transactions)'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
