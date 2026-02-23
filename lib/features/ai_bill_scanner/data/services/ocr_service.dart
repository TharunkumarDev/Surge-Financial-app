import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<RecognizedText> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText;
    } catch (e) {
      throw Exception('OCR processing failed: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
