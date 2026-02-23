import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/data/expense_repository.dart';
import '../domain/auto_transaction.dart';
import '../data/auto_tracking_repository.dart';
import '../providers/auto_tracking_providers.dart';
import '../../../core/theme/design_system.dart';
import 'package:intl/intl.dart';

class DetectedTransactionDialog extends ConsumerStatefulWidget {
  final AutoTransaction transaction;

  const DetectedTransactionDialog({super.key, required this.transaction});

  @override
  ConsumerState<DetectedTransactionDialog> createState() => _DetectedTransactionDialogState();
}

class _DetectedTransactionDialogState extends ConsumerState<DetectedTransactionDialog> {
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  ExpenseCategory _selectedCategory = ExpenseCategory.food; // Default
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount?.toStringAsFixed(2) ?? '');
    _merchantController = TextEditingController(text: widget.transaction.merchantName ?? '');
    _selectedDate = widget.transaction.receivedAt;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.limeAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/surge_logo.png',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.auto_awesome, 
                  color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "New Transaction Detected",
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We found a new transaction from SMS. Review and add it to your expenses.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : AppTheme.greyText,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _merchantController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Merchant / Title",
                labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                prefixIcon: Icon(Icons.store, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                prefixIcon: Icon(Icons.currency_rupee, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                prefixIcon: Icon(Icons.category),
              ),
              items: ExpenseCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 12),
            InputDatePickerFormField(
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDate: _selectedDate,
              onDateSubmitted: (date) => setState(() => _selectedDate = date),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Ignore
            final repo = await ref.read(autoTrackingRepositoryProvider.future);
            await repo.ignoreTransaction(widget.transaction.id);
            // Invalidate provider to refresh the list
            ref.invalidate(pendingTransactionsProvider);
            if (mounted) Navigator.pop(context);
          },
          child: Text("Ignore", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _saveExpense(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkGreen,
            foregroundColor: AppTheme.limeAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Add Expense"),
        ),
      ],
    );
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final merchant = _merchantController.text.trim();

    if (amount <= 0 || merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid amount and merchant")),
      );
      return;
    }

    try {
      final expenseRepo = await ref.read(expenseRepositoryProvider.future);
      final trackingRepo = await ref.read(autoTrackingRepositoryProvider.future);

      // Create Expense
      final newExpense = ExpenseItem()
        ..title = merchant
        ..amount = amount
        ..date = _selectedDate
        ..category = _selectedCategory
        ..category = _selectedCategory
        ..isRecurring = false // Default
        ..note = ""
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..deviceId = "unknown";

      // Save to Expense Repo
      await expenseRepo.addExpense(newExpense);

      // Mark as Processed in Auto Tracking Repo
      await trackingRepo.markAsProcessed(widget.transaction.id);
      
      // Invalidate provider to refresh the list
      ref.invalidate(pendingTransactionsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense added successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding expense: $e")),
        );
      }
    }
  }
}
