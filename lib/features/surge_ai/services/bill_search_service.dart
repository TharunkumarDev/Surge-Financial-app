import '../../expense/domain/expense_model.dart';
import '../../expense/data/expense_repository.dart';
import '../../expense/data/bill_image_repository.dart';
import '../../expense/domain/bill_image_model.dart';

/// Result of a bill search query
class BillSearchResult {
  final List<ExpenseItem> expenses;
  final List<BillImage> billImages;
  final String searchQuery;
  final ExpenseCategory? category;

  BillSearchResult({
    required this.expenses,
    required this.billImages,
    required this.searchQuery,
    this.category,
  });

  bool get hasResults => expenses.isNotEmpty;
  int get resultCount => expenses.length;
}

/// Service to handle bill search queries
class BillSearchService {
  final ExpenseRepository expenseRepository;
  final BillImageRepository billImageRepository;

  BillSearchService({
    required this.expenseRepository,
    required this.billImageRepository,
  });

  /// Search for bills based on user query
  Future<BillSearchResult> searchBills(String query) async {
    final normalizedQuery = query.toLowerCase().trim();

    // Detect if this is a bill search query
    if (!_isBillSearchQuery(normalizedQuery)) {
      return BillSearchResult(
        expenses: [],
        billImages: [],
        searchQuery: query,
      );
    }

    // Get all expenses
    final allExpenses = await expenseRepository.getAllExpenses();

    // Filter expenses that have bill images
    final expensesWithBills = allExpenses.where((expense) {
      return expense.billImageIds.isNotEmpty;
    }).toList();

    // Detect category filter
    final category = _detectCategory(normalizedQuery);

    // Filter by category if specified
    List<ExpenseItem> filteredExpenses = expensesWithBills;
    if (category != null) {
      filteredExpenses = expensesWithBills.where((expense) {
        return expense.category == category;
      }).toList();
    }

    // Search by OCR text if specific keywords present
    final searchKeywords = _extractSearchKeywords(normalizedQuery);
    if (searchKeywords.isNotEmpty) {
      filteredExpenses = await _filterByOcrText(filteredExpenses, searchKeywords);
    }

    // Get bill images for the filtered expenses
    final expenseIds = filteredExpenses.map((e) => e.id).toList();
    final billImages = await billImageRepository.getBillImagesByExpenseIds(expenseIds);

    return BillSearchResult(
      expenses: filteredExpenses,
      billImages: billImages,
      searchQuery: query,
      category: category,
    );
  }

  /// Search for expenses by category (without requiring bill images)
  Future<BillSearchResult> searchExpenses(String query) async {
    final normalizedQuery = query.toLowerCase().trim();

    // Detect if this is an expense search query
    if (!_isExpenseSearchQuery(normalizedQuery) && _detectCategory(normalizedQuery) == null) {
      return BillSearchResult(
        expenses: [],
        billImages: [],
        searchQuery: query,
      );
    }

    // Get all expenses
    final allExpenses = await expenseRepository.getAllExpenses();

    // Detect category filter
    final category = _detectCategory(normalizedQuery);

    // Filter by category if specified
    List<ExpenseItem> filteredExpenses = allExpenses;
    if (category != null) {
      filteredExpenses = allExpenses.where((expense) {
        return expense.category == category;
      }).toList();
    }

    // Search by keywords in title or note
    final searchKeywords = _extractSearchKeywords(normalizedQuery);
    if (searchKeywords.isNotEmpty && category == null) {
      filteredExpenses = allExpenses.where((expense) {
        final titleLower = expense.title.toLowerCase();
        final noteLower = (expense.note ?? '').toLowerCase();
        return searchKeywords.any((keyword) =>
            titleLower.contains(keyword) || noteLower.contains(keyword));
      }).toList();
    }

    // Get bill images for expenses that have them (optional)
    final expenseIds = filteredExpenses.map((e) => e.id).toList();
    final billImages = await billImageRepository.getBillImagesByExpenseIds(expenseIds);

    return BillSearchResult(
      expenses: filteredExpenses,
      billImages: billImages,
      searchQuery: query,
      category: category,
    );
  }

  /// Check if query is asking for bills
  bool _isBillSearchQuery(String query) {
    final billKeywords = ['bill', 'bills', 'receipt', 'receipts', 'invoice', 'invoices'];
    return billKeywords.any((keyword) => query.contains(keyword));
  }

  /// Check if query is asking for expenses
  bool _isExpenseSearchQuery(String query) {
    final expenseKeywords = ['expense', 'expenses', 'spending', 'spent', 'transaction', 'transactions'];
    return expenseKeywords.any((keyword) => query.contains(keyword));
  }

  /// Detect category from query
  ExpenseCategory? _detectCategory(String query) {
    for (final category in ExpenseCategory.values) {
      if (query.contains(category.name.toLowerCase())) {
        return category;
      }
    }
    return null;
  }

  /// Extract search keywords (excluding bill-related and category words)
  List<String> _extractSearchKeywords(String query) {
    final billKeywords = ['bill', 'bills', 'receipt', 'receipts', 'invoice', 'invoices', 'show', 'me', 'my', 'all', 'from'];
    final categoryNames = ExpenseCategory.values.map((c) => c.name.toLowerCase()).toList();
    
    final words = query.split(' ').where((word) {
      return word.isNotEmpty &&
             !billKeywords.contains(word) &&
             !categoryNames.contains(word);
    }).toList();

    return words;
  }

  /// Filter expenses by OCR text content
  Future<List<ExpenseItem>> _filterByOcrText(
    List<ExpenseItem> expenses,
    List<String> keywords,
  ) async {
    if (keywords.isEmpty) return expenses;

    final filtered = <ExpenseItem>[];
    
    for (final expense in expenses) {
      // Check expense OCR text
      if (expense.ocrText != null) {
        final ocrLower = expense.ocrText!.toLowerCase();
        if (keywords.any((keyword) => ocrLower.contains(keyword))) {
          filtered.add(expense);
          continue;
        }
      }

      // Check bill image OCR text
      final billImages = await billImageRepository.getBillImagesByExpenseIds([expense.id]);
      for (final billImage in billImages) {
        if (billImage.ocrText != null) {
          final ocrLower = billImage.ocrText!.toLowerCase();
          if (keywords.any((keyword) => ocrLower.contains(keyword))) {
            filtered.add(expense);
            break;
          }
        }
      }
    }

    return filtered;
  }

  /// Generate AI response message based on search results
  String generateResponseMessage(BillSearchResult result, {bool isExpenseSearch = false}) {
    if (!result.hasResults) {
      if (result.category != null) {
        if (isExpenseSearch) {
          return "I couldn't find any ${result.category!.name} expenses.";
        }
        return "I couldn't find any ${result.category!.name} bills in your expenses.";
      }
      if (isExpenseSearch) {
        return "I couldn't find any expenses matching your search.";
      }
      return "I couldn't find any bills matching your search.";
    }

    final count = result.resultCount;
    final itemWord = isExpenseSearch
        ? (count == 1 ? 'expense' : 'expenses')
        : (count == 1 ? 'bill' : 'bills');
    
    if (result.category != null) {
      return "I found $count ${result.category!.name} $itemWord:";
    }

    final keywords = _extractSearchKeywords(result.searchQuery.toLowerCase());
    if (keywords.isNotEmpty) {
      return "I found $count $itemWord matching '${keywords.join(' ')}':";
    }

    if (isExpenseSearch) {
      return "I found $count $itemWord:";
    }
    return "I found $count $itemWord in your expenses:";
  }
}
