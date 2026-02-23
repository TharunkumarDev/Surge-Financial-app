import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = 1; // Single user instance
  
  String username = 'User';
  String email = 'user@example.com';
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
