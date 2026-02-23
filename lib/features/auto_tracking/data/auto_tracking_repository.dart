import 'package:isar/isar.dart';
import '../../../../core/utils/isar_provider.dart';
import '../domain/auto_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_tracking_repository.g.dart';

class AutoTrackingRepository {
  final Isar isar;

  AutoTrackingRepository(this.isar);

  Future<void> saveTransaction(AutoTransaction transaction) async {
    await isar.writeTxn(() async {
      await isar.autoTransactions.put(transaction);
    });
  }

  Future<bool> isDuplicate(String hash) async {
    final count = await isar.autoTransactions
        .where()
        .hashEqualTo(hash)
        .count();
    return count > 0;
  }

  Future<List<AutoTransaction>> getPendingTransactions() async {
    return await isar.autoTransactions
        .filter()
        .isProcessedEqualTo(false)
        .isIgnoredEqualTo(false)
        .sortByReceivedAtDesc()
        .findAll();
  }

  Future<void> markAsProcessed(int id) async {
    final transaction = await isar.autoTransactions.get(id);
    if (transaction != null) {
      transaction.isProcessed = true;
      await isar.writeTxn(() async {
        await isar.autoTransactions.put(transaction);
      });
    }
  }

  Future<void> ignoreTransaction(int id) async {
    final transaction = await isar.autoTransactions.get(id);
    if (transaction != null) {
      transaction.isIgnored = true;
      await isar.writeTxn(() async {
        await isar.autoTransactions.put(transaction);
      });
    }
  }
}

@riverpod
Future<AutoTrackingRepository> autoTrackingRepository(AutoTrackingRepositoryRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return AutoTrackingRepository(isar);
}
