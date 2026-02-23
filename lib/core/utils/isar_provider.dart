import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expense/domain/expense_model.dart';
import '../../features/expense/domain/bill_image_model.dart';
import '../../features/wallet/domain/wallet_model.dart';
import '../../features/profile/domain/user_model.dart';
import '../../features/auto_tracking/domain/auto_transaction.dart';
import '../../features/surge_ai/domain/chat_message.dart';
import '../../features/auth/providers/auth_providers.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  // Watch auth state to react to login/logout
  final authState = ref.watch(authStateProvider);
  
  // We need to handle the AsyncValue properly
  // If loading or error, we might want to wait or throw
  final user = authState.valueOrNull; // Value or null
  
  if (user == null) {
    // Strict Isolation: No DB access without user
    // This effectively "pauses" the dependency graph or fails downstream
    // until persistence is restored via login.
    throw Exception('User not authenticated - Database access denied');
  }

  final dir = await getApplicationDocumentsDirectory();
  final dbName = 'db_${user.uid}';
  
  // Open user-scoped database
  final isar = await Isar.open(
    [
      ExpenseItemSchema,
      BillImageSchema,
      WalletSchema,
      UserSchema,
      AutoTransactionSchema,
      ChatMessageSchema,
    ],
    directory: dir.path,
    name: dbName,
  );
  
  // Ensure we close the DB when the user changes or provider is disposed
  ref.onDispose(() {
    if (isar.isOpen) {
      isar.close();
    }
  });

  return isar;
}
