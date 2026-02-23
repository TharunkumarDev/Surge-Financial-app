// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScannedReceiptImpl _$$ScannedReceiptImplFromJson(Map<String, dynamic> json) =>
    _$ScannedReceiptImpl(
      merchantName: json['merchantName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      isAiEnhanced: json['isAiEnhanced'] as bool? ?? false,
    );

Map<String, dynamic> _$$ScannedReceiptImplToJson(
        _$ScannedReceiptImpl instance) =>
    <String, dynamic>{
      'merchantName': instance.merchantName,
      'totalAmount': instance.totalAmount,
      'date': instance.date?.toIso8601String(),
      'items': instance.items,
      'confidenceScore': instance.confidenceScore,
      'isAiEnhanced': instance.isAiEnhanced,
    };

_$ReceiptItemImpl _$$ReceiptItemImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptItemImpl(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$ReceiptItemImplToJson(_$ReceiptItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
      'confidence': instance.confidence,
    };
