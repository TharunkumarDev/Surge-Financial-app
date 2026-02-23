import 'package:isar/isar.dart';

part 'wallet_model.g.dart';

@collection
class Wallet {
  Id id = 1; // Single wallet instance
  
  late double initialBalance;
  late DateTime lastUpdated;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  
  Wallet();
  
  Wallet.create({
    required this.initialBalance,
    String? deviceId,
  }) : lastUpdated = DateTime.now(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now(),
       deviceId = deviceId ?? 'unknown';

  Map<String, dynamic> toMap() {
    return {
      'initialBalance': initialBalance,
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet()
      ..initialBalance = (map['initialBalance'] as num).toDouble()
      ..lastUpdated = DateTime.parse(map['lastUpdated'] as String)
      ..createdAt = map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now()
      ..updatedAt = map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : DateTime.now()
      ..deviceId = map['deviceId'] as String? ?? 'unknown';
  }
}
