import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/scanned_receipt.dart';
import '../../../../core/theme/design_system.dart';
import 'package:intl/intl.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final ScannedReceipt receipt;

  const ScanResultScreen({super.key, required this.receipt});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _totalController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.receipt.merchantName);
    _totalController = TextEditingController(text: widget.receipt.totalAmount.toStringAsFixed(2));
    _selectedDate = widget.receipt.date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExpense,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfidenceCard(),
            const SizedBox(height: 24),
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: "Merchant",
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: "Total Amount",
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            
            const SizedBox(height: 32),
            const Text(
              "Detected Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final color = widget.receipt.confidenceScore > 0.8 
        ? Colors.green 
        : (widget.receipt.confidenceScore > 0.5 ? Colors.orange : Colors.red);
        
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/surge_logo.png',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                color: color, // Tint to match confidence color
                errorBuilder: (context, error, stackTrace) => Icon(Icons.auto_awesome, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.receipt.isAiEnhanced ? "AI Enhanced Extraction" : "Basic OCR Extraction",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Confidence: ${(widget.receipt.confidenceScore * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Date",
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate != null 
              ? DateFormat.yMMMd().format(_selectedDate!) 
              : "Select Date",
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (widget.receipt.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No items detected individually."),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.receipt.items.length,
      itemBuilder: (context, index) {
        final item = widget.receipt.items[index];
        return ListTile(
          title: Text(item.name),
          trailing: Text(item.price.toStringAsFixed(2)),
        );
      },
    );
  }

  void _saveExpense() {
    // Navigate to AddExpenseScreen with pre-filled data or return result
    // For now, we pop with result
    // Real integration involves pushing to AddExpense route with args
    final result = {
      'merchant': _merchantController.text,
      'amount': double.tryParse(_totalController.text) ?? 0.0,
      'date': _selectedDate,
    };
    // TODO: Actually save or pass to add expense
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Saved (Mock)")),
    );
    Navigator.pop(context); // Close scan result
    Navigator.pop(context); // Close camera screen
  }
}
