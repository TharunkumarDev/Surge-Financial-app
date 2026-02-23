import 'package:isar/isar.dart';

part 'bill_image_model.g.dart';

@collection
class BillImage {
  Id id = Isar.autoIncrement;
  
  late String imageId; // UUID for cloud reference
  
  @Index()
  late int expenseId; // Foreign key to ExpenseItem
  
  String? localPath; // Local file path
  String? cloudUrl; // Firebase Storage URL
  String? thumbnailPath; // Local thumbnail path
  
  String? ocrText; // Extracted text for search
  
  late DateTime createdAt;
  DateTime? uploadedAt; // When successfully uploaded to cloud
  
  bool isUploaded = false;
  bool uploadFailed = false;
  
  // Serialization for Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageId': imageId,
      'expenseId': expenseId,
      'localPath': localPath,
      'cloudUrl': cloudUrl,
      'thumbnailPath': thumbnailPath,
      'ocrText': ocrText,
      'createdAt': createdAt.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'isUploaded': isUploaded,
      'uploadFailed': uploadFailed,
    };
  }
  
  static BillImage fromMap(Map<String, dynamic> map) {
    return BillImage()
      ..imageId = map['imageId'] as String
      ..expenseId = map['expenseId'] as int
      ..localPath = map['localPath'] as String?
      ..cloudUrl = map['cloudUrl'] as String?
      ..thumbnailPath = map['thumbnailPath'] as String?
      ..ocrText = map['ocrText'] as String?
      ..createdAt = DateTime.parse(map['createdAt'] as String)
      ..uploadedAt = map['uploadedAt'] != null ? DateTime.parse(map['uploadedAt'] as String) : null
      ..isUploaded = map['isUploaded'] as bool? ?? false
      ..uploadFailed = map['uploadFailed'] as bool? ?? false;
  }
}
