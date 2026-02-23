import 'dart:io';
import 'package:image/image.dart' as img;

class BillImageProcessor {
  /// Prepares an image for TFLite inference.
  /// Resizes to [targetWidth] x [targetHeight] and converts to grayscale if needed.
  Future<List<int>> processImageForModel(
    File imageFile, {
    int targetWidth = 224,
    int targetHeight = 224,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Resize
    final resized = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // Convert to normalized float (or uint8 based on model)
    // For specific LayoutLM, we typically need normalized floats.
    // This is a placeholder implementation for the data buffer.
    return resized.getBytes();
  }
}
