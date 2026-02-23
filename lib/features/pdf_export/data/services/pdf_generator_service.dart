import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../expense/domain/expense_model.dart';
import 'pdf_branding_service.dart';

/// Service responsible for generating PDF documents from expense data
class PdfGeneratorService {
  final PdfBrandingService _brandingService;
  
  PdfGeneratorService(this._brandingService);
  
  /// Generate a comprehensive expense report PDF
  /// 
  /// [expenses] - List of expenses to include in the report
  /// [dateRange] - Optional date range for filtering (shown in header)
  /// [title] - Custom title for the report (default: "Expense Report")
  Future<pw.Document> generateExpensePdf({
    required List<ExpenseItem> expenses,
    DateTime? startDate,
    DateTime? endDate,
    String title = "Expense Report",
  }) async {
    final pdf = pw.Document();
    final logo = await _brandingService.loadAppLogo();
    final exportDate = DateTime.now();
    
    // Calculate summary statistics
    final totalAmount = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final averageAmount = expenses.isEmpty ? 0.0 : totalAmount / expenses.length;
    
    // Group expenses by category for better organization
    final expensesByCategory = <ExpenseCategory, List<ExpenseItem>>{};
    for (final expense in expenses) {
      expensesByCategory.putIfAbsent(expense.category, () => []).add(expense);
    }
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            pw.Stack(
              children: [
                // Watermark layer (behind content)
                _brandingService.buildWatermark(context.page.pageFormat, logo),
                // Content layer
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildHeader(title, startDate, endDate, expenses.length),
                    pw.SizedBox(height: 20),
                    _buildSummarySection(totalAmount, averageAmount, expenses.length),
                    pw.SizedBox(height: 30),
                    _buildExpensesTable(expenses),
                    if (expensesByCategory.length > 1) ...[
                      pw.SizedBox(height: 30),
                      _buildCategoryBreakdown(expensesByCategory),
                    ],
                  ],
                ),
              ],
            ),
          ];
        },
        header: (context) => _buildPageHeader(context, title),
        footer: (context) => _brandingService.buildFooter(
          context,
          logo,
          "Surge Financial",
          exportDate,
        ),
      ),
    );
    
    return pdf;
  }
  
  /// Build the main header section
  pw.Widget _buildHeader(
    String title,
    DateTime? startDate,
    DateTime? endDate,
    int expenseCount,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('132C19'), // AppTheme.darkGreen
          ),
        ),
        pw.SizedBox(height: 8),
        if (startDate != null && endDate != null)
          pw.Text(
            'Period: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        pw.Text(
          'Total Transactions: $expenseCount',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }
  
  /// Build page header (appears on every page)
  pw.Widget _buildPageHeader(pw.Context context, String title) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }
  
  /// Build summary statistics section
  pw.Widget _buildSummarySection(
    double totalAmount,
    double averageAmount,
    int count,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0x1AC7F25E), // AppTheme.limeAccent with 10% opacity
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Amount', '₹${totalAmount.toStringAsFixed(2)}'),
          _buildSummaryItem('Average', '₹${averageAmount.toStringAsFixed(2)}'),
          _buildSummaryItem('Transactions', count.toString()),
        ],
      ),
    );
  }
  
  /// Build individual summary item
  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('132C19'), // AppTheme.darkGreen
          ),
        ),
      ],
    );
  }
  
  /// Build expenses table
  pw.Widget _buildExpensesTable(List<ExpenseItem> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Date
        1: const pw.FlexColumnWidth(3), // Title
        2: const pw.FlexColumnWidth(2), // Category
        3: const pw.FlexColumnWidth(2), // Amount
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('132C19')), // AppTheme.darkGreen
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Description'),
            _buildTableHeader('Category'),
            _buildTableHeader('Amount'),
          ],
        ),
        // Data rows
        ...expenses.map((expense) => pw.TableRow(
          children: [
            _buildTableCell(_formatDate(expense.date)),
            _buildTableCell(expense.title),
            _buildTableCell(_getCategoryName(expense.category)),
            _buildTableCell('₹${expense.amount.toStringAsFixed(2)}', isAmount: true),
          ],
        )),
      ],
    );
  }
  
  /// Build table header cell
  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }
  
  /// Build table data cell
  pw.Widget _buildTableCell(String text, {bool isAmount = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey700,
          fontWeight: isAmount ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isAmount ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }
  
  /// Build category breakdown section
  pw.Widget _buildCategoryBreakdown(
    Map<ExpenseCategory, List<ExpenseItem>> expensesByCategory,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Category Breakdown',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableHeader('Category'),
                _buildTableHeader('Count'),
                _buildTableHeader('Total'),
              ],
            ),
            ...expensesByCategory.entries.map((entry) {
              final total = entry.value.fold<double>(
                0.0,
                (sum, expense) => sum + expense.amount,
              );
              return pw.TableRow(
                children: [
                  _buildTableCell(_getCategoryName(entry.key)),
                  _buildTableCell(entry.value.length.toString()),
                  _buildTableCell('₹${total.toStringAsFixed(2)}', isAmount: true),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
  
  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Get category display name
  String _getCategoryName(ExpenseCategory category) {
    return category.name.toUpperCase();
  }
}
