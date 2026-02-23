import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanned_receipt.freezed.dart';
part 'scanned_receipt.g.dart';

@freezed
class ScannedReceipt with _$ScannedReceipt {
  const factory ScannedReceipt({
    required String merchantName,
    required double totalAmount,
    required DateTime? date,
    @Default([]) List<ReceiptItem> items,
    @Default(0.0) double confidenceScore,
    @Default(false) bool isAiEnhanced,
  }) = _ScannedReceipt;

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) => 
      _$ScannedReceiptFromJson(json);
}

@freezed
class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String name,
    required double price,
    @Default(1) int quantity,
    @Default(0.0) double confidence,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => 
      _$ReceiptItemFromJson(json);
}
