import 'package:isar/isar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../domain/user_model.dart';

class UserRepository {
  final Isar isar;

  UserRepository(this.isar);

  /// Get the current user or create a default one
  Future<User> getUser() async {
    var user = await isar.users.get(1);
    if (user == null) {
      user = User();
      // Try to get name from Firebase Auth if available (for new users)
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser?.displayName != null && firebaseUser!.displayName!.isNotEmpty) {
        user.username = firebaseUser.displayName!;
      }
      
      await isar.writeTxn(() async {
        await isar.users.put(user!);
      });
    }
    return user!;
  }

  /// Update user profile
  Future<void> updateUser(String username, String email) async {
    final user = await getUser();
    user.username = username;
    user.email = email;
    user.updatedAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  /// Watch user changes
  Stream<User?> watchUser() {
    return isar.users.watchObject(1, fireImmediately: true);
  }
}
