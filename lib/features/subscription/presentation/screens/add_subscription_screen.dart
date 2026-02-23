import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/subscription_model.dart';
import '../../providers/subscription_tracker_providers.dart';
import '../../../../core/services/reminder_service.dart';
import '../../../../core/widgets/success_overlay.dart';
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 1));
  BillingCycle _billingCycle = BillingCycle.monthly;
  final List<int> _reminderDays = [3, 1, 0];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : AppTheme.darkGreen, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('New Subscription', 
          style: AppTheme.heading2.copyWith(color: isDark ? Colors.white : AppTheme.darkGreen)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Details', isDark),
              const SizedBox(height: 16),
              _buildModernCard(
                isDark,
                child: Column(
                  children: [
                    _buildModernTextField(
                      label: 'Subscription Name',
                      controller: _nameController,
                      icon: Icons.label_important_outline,
                      isDark: isDark,
                      hint: 'e.g. Netflix, Spotify',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, thickness: 0.5, color: Colors.black12),
                    ),
                    _buildModernTextField(
                      label: 'Monthly Amount',
                      controller: _amountController,
                      icon: Icons.currency_rupee_rounded,
                      isDark: isDark,
                      isNumber: true,
                      hint: '0.00',
                      suffixText: '₹',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Billing & Schedule', isDark),
              const SizedBox(height: 16),
              _buildModernCard(
                isDark,
                child: Column(
                  children: [
                    _buildModernDatePicker(context, isDark),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, thickness: 0.5, color: Colors.black12),
                    ),
                    _buildModernBillingCycleSelector(isDark),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('Smart Reminders', isDark),
              const SizedBox(height: 16),
              _buildModernCard(
                isDark,
                child: _buildModernReminderSelector(isDark),
              ),

              const SizedBox(height: 48),
              _buildPremiumButton(isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: AppTheme.bodySmall.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: isDark ? Colors.white54 : AppTheme.darkGreen.withOpacity(0.5),
      ),
    );
  }

  Widget _buildModernCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    bool isNumber = false,
    String? hint,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: AppTheme.heading3.copyWith(
            color: isDark ? Colors.white : AppTheme.darkGreen,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: (isDark ? Colors.white : AppTheme.darkGreen).withOpacity(0.2)),
            suffixText: suffixText,
            suffixStyle: AppTheme.heading3.copyWith(color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildModernDatePicker(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next Due Date', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM dd, yyyy').format(_nextDueDate),
              style: AppTheme.heading3.copyWith(color: isDark ? Colors.white : AppTheme.darkGreen),
            ),
          ],
        ),
        Material(
          color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _nextDueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                builder: (context, child) => Theme(
                  data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
                  child: child!,
                ),
              );
              if (date != null) setState(() => _nextDueDate = date);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.calendar_month_rounded,
                color: isDark ? AppTheme.darkGreen : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernBillingCycleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing Cycle', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: BillingCycle.values.map((cycle) {
              final isSelected = _billingCycle == cycle;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: isSelected 
                    ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _billingCycle = cycle),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        cycle.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected 
                            ? (isDark ? AppTheme.darkGreen : Colors.white)
                            : (isDark ? Colors.white70 : AppTheme.darkGreen.withOpacity(0.7)),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModernReminderSelector(bool isDark) {
    final options = [5, 3, 1, 0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Remind Me', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((days) {
            final isSelected = _reminderDays.contains(days);
            final label = days == 0 ? 'Due' : '$days Days';
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: isSelected 
                  ? (isDark ? AppTheme.limeAccent : AppTheme.darkGreen)
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _reminderDays.remove(days);
                      } else {
                        _reminderDays.add(days);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected 
                          ? (isDark ? AppTheme.darkGreen : Colors.white)
                          : (isDark ? Colors.white70 : AppTheme.darkGreen.withOpacity(0.7)),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPremiumButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.premiumGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.limeAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSubscription,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading 
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkGreen),
              ),
            )
          : Text(
              'Track Subscription',
              style: TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }

  void _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(subscriptionTrackerRepositoryProvider);
      if (repo == null) throw Exception('Subscription Repository not found');

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final user = ref.read(authStateProvider).value;
      
      final subscription = SubscriptionModel(
        id: id,
        userId: user?.uid ?? '',
        name: _nameController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        billingCycle: _billingCycle,
        nextDueDate: _nextDueDate,
        reminderDays: _reminderDays,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.addSubscription(subscription);
      
      // Schedule Reminders (non-blocking failure)
      try {
        await ReminderService().schedulePaymentReminders(
          id: id,
          title: subscription.name,
          dueDate: _nextDueDate,
          reminderDays: _reminderDays,
          type: 'Subscription',
        );
      } catch (e) {
        debugPrint('🔔 Reminder scheduling failed: $e');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        SuccessOverlay.show(
          context,
          message: 'Subscription Tracked!',
          onFinished: () => context.pop(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving subscription: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save subscription: ${e.toString()}'),
            backgroundColor: AppTheme.destructive,
          ),
        );
      }
    }
  }
}
