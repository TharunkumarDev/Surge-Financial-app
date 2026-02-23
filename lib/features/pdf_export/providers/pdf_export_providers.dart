import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/pdf_branding_service.dart';
import '../data/services/pdf_generator_service.dart';
import '../data/services/pdf_export_service.dart';

/// Provider for PDF branding service (singleton)
final pdfBrandingServiceProvider = Provider<PdfBrandingService>((ref) {
  return PdfBrandingService();
});

/// Provider for PDF generator service
final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  final brandingService = ref.watch(pdfBrandingServiceProvider);
  return PdfGeneratorService(brandingService);
});

/// Provider for PDF export service (main orchestrator)
final pdfExportServiceProvider = Provider<PdfExportService>((ref) {
  final brandingService = ref.watch(pdfBrandingServiceProvider);
  final generatorService = ref.watch(pdfGeneratorServiceProvider);
  return PdfExportService(brandingService, generatorService);
});
