import 'dart:io';
import '../models/scanned_receipt.dart';

abstract class BillScannerRepository {
  /// Process an image file and extract receipt data.
  /// 
  /// Uses a combination of OCR and AI (LayoutLM) if available,
  /// or falls back to heuristic extraction.
  Future<ScannedReceipt> scanReceipt(File imageFile);

  /// Checks if the AI model is ready/downloaded.
  Future<bool> isAiModelReady();
}
