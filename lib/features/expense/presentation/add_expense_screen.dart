import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/expense_repository.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../subscription/presentation/widgets/upgrade_dialog.dart';
import '../../../core/providers/currency_provider.dart';
import '../domain/expense_model.dart';
import '../domain/bill_image_model.dart';
import 'widgets/image_picker_widget.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../../core/utils/isar_provider.dart';
import '../../../core/providers/receipt_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final String? initialTitle;
  final DateTime? initialDate;
  final String? scannedImagePath; // Path to scanned bill image

  const AddExpenseScreen({
    super.key,
    this.initialAmount,
    this.initialTitle,
    this.initialDate,
    this.scannedImagePath,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _titleCtrl;
  late DateTime _selectedDate;
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isLoading = false;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.initialAmount?.toStringAsFixed(2) ?? '');
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
    
    // Auto-load scanned image if provided
    if (widget.scannedImagePath != null) {
      _selectedImages = [File(widget.scannedImagePath!)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text("Add Transaction", style: TextStyle(color: isDark ? Colors.white : AppTheme.darkGreen)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_down, color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Section
                    Center(
                      child: Column(
                        children: [
                          Text("Amount", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.greyText)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                               Text(
                                currency.symbol,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.darkGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 200,
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _amountCtrl,
                                  textAlign: TextAlign.center,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppTheme.darkGreen,
                                    height: 1.1,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "0",
                                    hintStyle: TextStyle(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Title Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: isDark ? Colors.white54 : AppTheme.greyText,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _titleCtrl,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : AppTheme.darkGreen,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "What is this for?",
                                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Category Section
                    Text("Category", style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.darkGreen,
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ExpenseCategory.values.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return _buildCategoryChip(cat, isSelected);
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    
                    // Image Picker
                    ImagePickerWidget(
                      selectedImages: _selectedImages,
                      onImageAdded: (file) => setState(() => _selectedImages.add(file)),
                      onImageRemoved: (index) => setState(() => _selectedImages.removeAt(index)),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    
                    // Date Picker
                    Text("Date", style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.darkGreen,
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                               DateFormat.yMMMd().format(_selectedDate),
                               style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                                 color: isDark ? Colors.white : Colors.black,
                               ),
                             ),
                             Icon(
                               Icons.calendar_today_rounded, 
                               size: 20, 
                               color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen
                             ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.limeAccent.withOpacity(0.4),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: AppTheme.darkGreen, strokeWidth: 2.5)
                          )
                        : Text(
                            "Save Transaction",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.darkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ExpenseCategory category, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryData = _getCategoryData(category);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.limeAccent 
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.limeAccent 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.limeAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryData['icon'],
              size: 18,
              color: isSelected ? AppTheme.darkGreen : (isDark ? Colors.white70 : AppTheme.darkGreen),
            ),
            const SizedBox(width: 8),
            Text(
              categoryData['label'],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? AppTheme.darkGreen 
                    : (isDark ? Colors.white70 : AppTheme.darkGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return {'icon': Icons.restaurant_rounded, 'label': 'Food'};
      case ExpenseCategory.transport:
        return {'icon': Icons.directions_car_rounded, 'label': 'Transport'};
      case ExpenseCategory.utilities:
        return {'icon': Icons.lightbulb_rounded, 'label': 'Utilities'};
      case ExpenseCategory.entertainment:
        return {'icon': Icons.movie_rounded, 'label': 'Entertainment'};
      case ExpenseCategory.shopping:
        return {'icon': Icons.shopping_bag_rounded, 'label': 'Shopping'};
      case ExpenseCategory.health:
        return {'icon': Icons.favorite_rounded, 'label': 'Health'};
      case ExpenseCategory.education:
        return {'icon': Icons.school_rounded, 'label': 'Education'};
      case ExpenseCategory.travel:
        return {'icon': Icons.flight_rounded, 'label': 'Travel'};
      case ExpenseCategory.other:
        return {'icon': Icons.more_horiz_rounded, 'label': 'Other'};
    }
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = await ref.read(expenseRepositoryProvider.future);
      final imageStorage = ref.read(imageStorageServiceProvider);
      final isar = await ref.read(isarProvider.future);
      
      // Create expense first
      final expense = ExpenseItem()
        ..amount = amount
        ..title = _titleCtrl.text
        ..date = _selectedDate
        ..category = _selectedCategory
        ..isRecurring = false
        ..note = ""
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..deviceId = "unknown";

      // Save expense to get ID
      await repo.addExpense(expense);
      
      // Process and save bill images
      if (_selectedImages.isNotEmpty) {
        final billImages = <BillImage>[];
        final imageIds = <String>[];
        
        for (final imageFile in _selectedImages) {
          try {
            // Generate unique image ID
            final imageId = const Uuid().v4();
            
            // Save image locally
            final localPath = await imageStorage.saveImageLocally(imageFile, expense.id.toString());
            
            // Generate thumbnail
            final thumbnailPath = await imageStorage.generateThumbnail(localPath);
            
            // Create BillImage record
            final billImage = BillImage()
              ..imageId = imageId
              ..expenseId = expense.id
              ..localPath = localPath
              ..thumbnailPath = thumbnailPath
              ..createdAt = DateTime.now()
              ..isUploaded = false;
            
            billImages.add(billImage);
            imageIds.add(imageId);
          } catch (e) {
            print('Error saving image: $e');
          }
        }
        
        // Save BillImage records to Isar
        await isar.writeTxn(() async {
          await isar.billImages.putAll(billImages);
          
          // Update expense with image IDs
          expense.billImageIds = imageIds;
          await isar.expenseItems.put(expense);
        });
        
        // TODO: Queue images for background cloud upload
        // This will be handled by SyncCoordinator in next phase
      }
      
      if (mounted) context.pop();
    } on InsufficientPermissionException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => UpgradeDialog(
            featureName: e.featureName,
            minimumTier: e.minimumTier,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }
}
