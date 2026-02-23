import 'package:isar/isar.dart';

part 'auto_transaction.g.dart';

@collection
class AutoTransaction {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String hash; // Unique hash to prevent duplicates (sender + amount + timestamp)

  late String originalSmsBody;
  late String senderId;
  late DateTime receivedAt;
  
  double? amount;
  String? merchantName;
  
  @enumerated
  late TransactionType type;
  
  bool isProcessed = false; // True if user has added it as expense or dismissed it
  bool isIgnored = false;   // True if user explicitly ignored this transaction

  AutoTransaction({
    required this.hash,
    required this.originalSmsBody,
    required this.senderId,
    required this.receivedAt,
    this.amount,
    this.merchantName,
    this.type = TransactionType.unknown,
    this.isProcessed = false,
    this.isIgnored = false,
  });
}

enum TransactionType {
  debit,
  credit,
  unknown;

  bool get isDebit => this == TransactionType.debit;
}
