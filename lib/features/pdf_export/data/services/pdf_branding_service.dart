import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service responsible for adding branding elements (watermarks and footers) to PDFs
class PdfBrandingService {
  pw.ImageProvider? _cachedLogo;
  
  /// Load and cache the app logo for reuse across pages
  Future<pw.ImageProvider> loadAppLogo() async {
    if (_cachedLogo != null) return _cachedLogo!;
    
    // Load the logo from assets
    final ByteData data = await rootBundle.load('assets/images/surge_logo_black.png');
    final Uint8List bytes = data.buffer.asUint8List();
    
    _cachedLogo = pw.MemoryImage(bytes);
    return _cachedLogo!;
  }
  
  /// Add a centered watermark to the page with 10% opacity
  /// 
  /// The watermark is placed behind all content and scaled to fit the page
  /// while maintaining aspect ratio.
  pw.Widget buildWatermark(PdfPageFormat pageFormat, pw.ImageProvider logo) {
    // Calculate watermark size (40% of page width)
    final watermarkSize = pageFormat.width * 0.4;
    
    return pw.Positioned(
      left: (pageFormat.width - watermarkSize) / 2,
      top: (pageFormat.height - watermarkSize) / 2,
      child: pw.Opacity(
        opacity: 0.1, // 10% opacity as required
        child: pw.Image(
          logo,
          width: watermarkSize,
          height: watermarkSize,
          fit: pw.BoxFit.contain,
        ),
      ),
    );
  }
  
  /// Build a footer widget with app logo and name
  /// 
  /// Footer appears on every page and includes:
  /// - Left: App logo (24x24)
  /// - Center: App name
  /// - Right: Export date
  pw.Widget buildFooter(
    pw.Context context,
    pw.ImageProvider logo,
    String appName,
    DateTime exportDate,
  ) {
    return pw.Container(
      height: 40,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F7F7F7'), // AppTheme.backgroundLight
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo + App Name
          pw.Row(
            children: [
              pw.Image(logo, width: 24, height: 24),
              pw.SizedBox(width: 8),
              pw.Text(
                appName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
          // Right: Export Date
          pw.Text(
            'Exported: ${_formatDate(exportDate)}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Format date for footer display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Clear cached logo (useful for testing or memory management)
  void clearCache() {
    _cachedLogo = null;
  }
}
