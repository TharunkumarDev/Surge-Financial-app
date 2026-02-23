import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../expense/domain/expense_model.dart';
import 'pdf_branding_service.dart';
import 'pdf_generator_service.dart';

/// Orchestrator service that combines PDF generation with branding
/// and handles file saving and sharing
class PdfExportService {
  final PdfBrandingService _brandingService;
  final PdfGeneratorService _generatorService;
  
  PdfExportService(this._brandingService, this._generatorService);
  
  /// Export expenses as a branded PDF and share it
  /// 
  /// Returns the file path of the generated PDF
  Future<String> exportExpensesAsPdf({
    required List<ExpenseItem> expenses,
    DateTime? startDate,
    DateTime? endDate,
    String title = "Expense Report",
  }) async {
    // Generate PDF with branding
    final pdf = await _generatorService.generateExpensePdf(
      expenses: expenses,
      startDate: startDate,
      endDate: endDate,
      title: title,
    );
    
    // Save to temporary directory
    final output = await _savePdfToFile(pdf, title);
    
    return output.path;
  }
  
  /// Share the generated PDF
  Future<void> sharePdf(String filePath, String title) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: title,
      text: 'Here is your expense report from Surge Financial',
    );
  }
  
  /// Export and immediately share
  Future<void> exportAndShare({
    required List<ExpenseItem> expenses,
    DateTime? startDate,
    DateTime? endDate,
    String title = "Expense Report",
  }) async {
    final filePath = await exportExpensesAsPdf(
      expenses: expenses,
      startDate: startDate,
      endDate: endDate,
      title: title,
    );
    
    await sharePdf(filePath, title);
  }
  
  /// Save PDF document to file
  Future<File> _savePdfToFile(pw.Document pdf, String title) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${title.replaceAll(' ', '_')}_$timestamp.pdf';
    final file = File('${dir.path}/$fileName');
    
    await file.writeAsBytes(bytes);
    return file;
  }
}
