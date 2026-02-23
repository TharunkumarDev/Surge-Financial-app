import 'dart:io';

import '../../domain/models/scanned_receipt.dart';
import '../../domain/repositories/bill_scanner_repository.dart';
import '../services/layoutlm_service.dart';
import '../services/ocr_service.dart';

class BillScannerRepositoryImpl implements BillScannerRepository {
  final OcrService _ocrService;
  final LayoutLmService _layoutLmService;

  BillScannerRepositoryImpl(this._ocrService, this._layoutLmService);

  @override
  Future<ScannedReceipt> scanReceipt(File imageFile) async {
    // 1. Perform OCR
    final recognizedText = await _ocrService.processImage(imageFile);

    // 2. Run LayoutLM (or fallback) extraction
    final receipt = await _layoutLmService.extractReceiptData(recognizedText);

    return receipt;
  }

  @override
  Future<bool> isAiModelReady() async {
    // Implementation can check if model file exists
    // For now we assume true as we have a fallback
    return true; 
  }
}
