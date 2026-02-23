import 'package:isar/isar.dart';
import '../../features/expense/domain/expense_model.dart';
import '../../features/expense/domain/bill_image_model.dart';

class ReceiptIndexService {
  final Isar isar;

  ReceiptIndexService(this.isar);

  /// Index an expense's OCR text for search
  Future<void> indexExpense(ExpenseItem expense, List<BillImage> images) async {
    // Combine all OCR text from bill images
    final ocrTexts = images.where((img) => img.ocrText != null).map((img) => img.ocrText!);
    final combinedText = ocrTexts.join(' ').toLowerCase();
    
    await isar.writeTxn(() async {
      expense.ocrText = combinedText.isNotEmpty ? combinedText : null;
      await isar.expenseItems.put(expense);
    });
  }

  /// Search receipts by text (merchant name, OCR text, title)
  Future<List<ExpenseItem>> searchReceipts(String query) async {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    
    // Search in title, note, and OCR text
    final results = await isar.expenseItems
        .filter()
        .group((q) => q
            .titleContains(lowerQuery, caseSensitive: false)
            .or()
            .noteContains(lowerQuery, caseSensitive: false)
            .or()
            .ocrTextContains(lowerQuery, caseSensitive: false))
        .sortByDateDesc()
        .findAll();
    
    return results;
  }

  /// Filter by date range
  Future<List<ExpenseItem>> filterByDateRange(DateTime start, DateTime end) async {
    return await isar.expenseItems
        .filter()
        .dateBetween(start, end, includeUpper: true)
        .sortByDateDesc()
        .findAll();
  }

  /// Filter by amount range
  Future<List<ExpenseItem>> filterByAmount(double min, double max) async {
    return await isar.expenseItems
        .filter()
        .amountBetween(min, max)
        .sortByDateDesc()
        .findAll();
  }

  /// Filter by category
  Future<List<ExpenseItem>> filterByCategory(ExpenseCategory category) async {
    return await isar.expenseItems
        .filter()
        .categoryEqualTo(category)
        .sortByDateDesc()
        .findAll();
  }

  /// Advanced search with multiple filters
  Future<List<ExpenseItem>> advancedSearch({
    String? textQuery,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    ExpenseCategory? category,
  }) async {
    // Start with all expenses
    final allExpenses = await isar.expenseItems.where().sortByDateDesc().findAll();
    
    // Apply filters manually
    var filtered = allExpenses.where((expense) {
      // Text search
      if (textQuery != null && textQuery.isNotEmpty) {
        final lowerQuery = textQuery.toLowerCase();
        final matchesTitle = expense.title.toLowerCase().contains(lowerQuery);
        final matchesNote = expense.note?.toLowerCase().contains(lowerQuery) ?? false;
        final matchesOcr = expense.ocrText?.toLowerCase().contains(lowerQuery) ?? false;
        if (!matchesTitle && !matchesNote && !matchesOcr) return false;
      }

      // Date range
      if (startDate != null && endDate != null) {
        if (expense.date.isBefore(startDate) || expense.date.isAfter(endDate)) {
          return false;
        }
      }

      // Amount range
      if (minAmount != null && maxAmount != null) {
        if (expense.amount < minAmount || expense.amount > maxAmount) {
          return false;
        }
      }

      // Category
      if (category != null && expense.category != category) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  /// Get all expenses with bill images (for archive)
  Future<List<ExpenseItem>> getExpensesWithImages({int offset = 0, int limit = 20}) async {
    return await isar.expenseItems
        .filter()
        .billImageIdsIsNotEmpty()
        .sortByDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  /// Get total count of expenses with images
  Future<int> getTotalReceiptCount() async {
    return await isar.expenseItems
        .filter()
        .billImageIdsIsNotEmpty()
        .count();
  }

  /// Watch expenses with images (for real-time updates)
  Stream<List<ExpenseItem>> watchExpensesWithImages({int offset = 0, int limit = 20}) {
    return isar.expenseItems
        .filter()
        .billImageIdsIsNotEmpty()
        .sortByDateDesc()
        .offset(offset)
        .limit(limit)
        .watch(fireImmediately: true);
  }
}
