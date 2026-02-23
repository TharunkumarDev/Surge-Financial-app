import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'services/advanced_heuristic_parser.dart';

class BillDetails {
  final double? amount;
  final DateTime? date;
  final String? merchantName;

  BillDetails({this.amount, this.date, this.merchantName});
}

class ScannerService {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  // final _layoutLm = LayoutLmService(); // Removed in favor of AdvancedHeuristicParser

  ScannerService();

  Future<File?> pickImage({ImageSource source = ImageSource.camera}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  Future<BillDetails> scanBill(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    // Use Advanced Heuristic Parser for strict compliance
    final heuristicParser = AdvancedHeuristicParser();
    final result = heuristicParser.parseReceiptText(recognizedText.text);

    return BillDetails(
      amount: result.amount,
      date: result.date,
      merchantName: result.merchantName,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
