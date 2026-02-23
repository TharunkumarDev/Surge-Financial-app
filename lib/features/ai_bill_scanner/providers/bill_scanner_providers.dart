import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/ocr_service.dart';
import '../data/services/layoutlm_service.dart';
import '../data/repositories/bill_scanner_repository_impl.dart';
import '../domain/repositories/bill_scanner_repository.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

final layoutLmServiceProvider = Provider<LayoutLmService>((ref) {
  final service = LayoutLmService();
  service.initialize(); // Fire and forget initialization
  return service;
});

final billScannerRepositoryProvider = Provider<BillScannerRepository>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  final layoutLmService = ref.watch(layoutLmServiceProvider);
  return BillScannerRepositoryImpl(ocrService, layoutLmService);
});
