import 'package:isar/isar.dart';

part 'expense_model.g.dart';

@collection
class ExpenseItem {
  Id id = Isar.autoIncrement;

  late double amount;
  
  late String title;
  
  late String? note;
  
  late DateTime date;

  @Enumerated(EnumType.name)
  late ExpenseCategory category;
  
  late bool isRecurring;

  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
  
  late String deviceId;
  
  // Receipt archive fields
  List<String> billImageIds = []; // References to BillImage.imageId
  String? ocrText; // Searchable OCR text from all bill images

  ExpenseItem();

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'title': title,
      'note': note,
      'date': date.toIso8601String(),
      'category': category.name,
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      'billImageIds': billImageIds,
      'ocrText': ocrText,
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map, {int? isarId}) {
    final item = ExpenseItem()
      ..amount = (map['amount'] as num).toDouble()
      ..title = map['title'] as String
      ..note = map['note'] as String?
      ..date = DateTime.parse(map['date'] as String)
      ..category = ExpenseCategory.values.byName(map['category'] as String)
      ..isRecurring = map['isRecurring'] as bool
      ..createdAt = map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now()
      ..updatedAt = map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : DateTime.now()
      ..deviceId = map['deviceId'] as String? ?? 'unknown'
      ..billImageIds = (map['billImageIds'] as List<dynamic>?)?.cast<String>() ?? []
      ..ocrText = map['ocrText'] as String?;
    if (isarId != null) item.id = isarId;
    return item;
  }
}

enum ExpenseCategory {
  food,
  transport,
  utilities,
  entertainment,
  shopping,
  health,
  education,
  travel,
  other
}
