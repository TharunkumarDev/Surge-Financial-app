import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../expense/domain/expense_model.dart';
import '../../wallet/data/wallet_repository.dart';

class ReportGenerator {
  static Future<void> generateAndDownload(
      List<ExpenseItem> expenses, 
      WalletStats stats, 
      String timeRange,
      String currencySymbol
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Calculate totals
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final categoryTotals = <ExpenseCategory, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        ),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Expense Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateFormat('MMM dd, yyyy').format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Summary ($timeRange)", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Spent:"),
                    pw.Text("$currencySymbol${totalSpent.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Transaction Count:"),
                    pw.Text("${expenses.length}"),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          
          // Category Breakdown
          pw.Text("Category Breakdown", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...categoryTotals.entries.map((e) {
             final pct = (totalSpent > 0 ? (e.value / totalSpent * 100) : 0).toStringAsFixed(1);
             return pw.Padding(
               padding: const pw.EdgeInsets.symmetric(vertical: 4),
               child: pw.Row(
                 children: [
                   pw.Expanded(child: pw.Text(e.key.name.toUpperCase())),
                   pw.Text("$currencySymbol${e.value.toStringAsFixed(2)} ($pct%)"),
                 ],
               ),
             );
          }),
          pw.SizedBox(height: 30),

          // Transaction Table
          pw.Text("Detailed Transactions", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Note', 'Amount'],
            data: expenses.map((e) => [
              DateFormat('MM/dd').format(e.date),
              e.category.name.toUpperCase(),
              (e.note ?? "").isEmpty ? "-" : e.note!,
              "$currencySymbol${e.amount.toStringAsFixed(2)}",
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'expense_report_$timeRange.pdf');
  }
}
