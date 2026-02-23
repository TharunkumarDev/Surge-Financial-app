import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cloud_sync_repository.dart';
import 'firestore_listener_manager.dart';
import 'device_info_service.dart';
import '../../features/expense/domain/expense_model.dart';
import '../../features/wallet/domain/wallet_model.dart';
import '../../features/subscription/providers/subscription_providers.dart';
import '../../features/subscription/domain/subscription_model.dart';
import '../../features/loan/domain/loan_model.dart';
import '../utils/isar_provider.dart';

class SyncCoordinator {
  final Isar isar;
  final CloudSyncRepository remoteRepo;
  final FirestoreListenerManager listenerManager;
  final DeviceInfoService deviceInfo;
  
  StreamSubscription? _expenseChangeSubscription;
  StreamSubscription? _walletChangeSubscription;
  StreamSubscription? _loanChangeSubscription;
  StreamSubscription? _subscriptionChangeSubscription;

  SyncCoordinator({
    required this.isar,
    required this.remoteRepo,
    required this.listenerManager,
    required this.deviceInfo,
  });

  void start() {
    listenerManager.attachListeners();
    
    // Listen for remote expense changes
    _expenseChangeSubscription = listenerManager.expenseChanges.listen((change) {
      _handleRemoteExpenseChange(change);
    });

    // Listen for remote wallet changes
    _walletChangeSubscription = listenerManager.walletChanges.listen((snapshot) {
      _handleRemoteWalletChange(snapshot);
    });

    // Listen for remote loan changes
    _loanChangeSubscription = listenerManager.loanChanges.listen((change) {
      _handleRemoteLoanChange(change);
    });

    // Listen for remote subscription changes
    _subscriptionChangeSubscription = listenerManager.subscriptionChanges.listen((change) {
      _handleRemoteSubscriptionChange(change);
    });

    // Initial Full Sync in background
    _performInitialSync();
  }

  Future<void> sync({bool force = false}) async {
    await _performInitialSync();
  }

  Future<void> _performInitialSync() async {
    // 1. Sync Wallet
    final remoteWallet = await remoteRepo.fetchWallet();
    if (remoteWallet != null) {
      final localWallet = await isar.wallets.get(1);
      if (localWallet == null || remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
        await isar.writeTxn(() async => await isar.wallets.put(remoteWallet));
      } else if (localWallet.updatedAt.isAfter(remoteWallet.updatedAt)) {
        await remoteRepo.pushWallet(localWallet);
      }
    }

    // 2. Delta Sync Expenses
    // For simplicity in the first version, we'll fetch everything if it's a first time sync, 
    // or just fetch changes from the last 24 hours.
    // In a full production app, you'd store 'pulse' or 'lastSync' timestamp.
    final lastSyncStr = await isar.expenseItems.where().sortByUpdatedAtDesc().findFirst();
    final lastSyncTime = lastSyncStr?.updatedAt ?? DateTime(2020);
    
    final deltas = await remoteRepo.fetchExpenseDeltas(lastSyncTime);
    if (deltas.isNotEmpty) {
      await isar.writeTxn(() async {
        for (var remoteItem in deltas) {
          final localItem = await isar.expenseItems.get(remoteItem.id);
          if (localItem == null || remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
            await isar.expenseItems.put(remoteItem);
          }
        }
      });
    }

    // 3. Push local changes that haven't been synced (where deviceId == current)
    // This is optional but good for robustness
    final unsynced = await isar.expenseItems.where().findAll(); // Simplified
    // Filter logic would be needed here for more efficiency
  }

  Future<void> _handleRemoteExpenseChange(DocumentChange<Map<String, dynamic>> change) async {
    final data = change.doc.data();
    if (data == null) return;

    final remoteItem = ExpenseItem.fromMap(data, isarId: int.tryParse(change.doc.id));
    
    // Skip if it's from the same device to prevent loops
    if (remoteItem.deviceId == deviceInfo.getDeviceId()) return;

    await isar.writeTxn(() async {
      final localItem = await isar.expenseItems.get(remoteItem.id);

      if (change.type == DocumentChangeType.removed) {
        if (localItem != null) await isar.expenseItems.delete(localItem.id);
      } else {
        // Added or Modified
        if (localItem == null || remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          await isar.expenseItems.put(remoteItem);
        }
      }
    });
  }

  Future<void> _handleRemoteWalletChange(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final data = snapshot.data();
    if (data == null) return;

    final remoteWallet = Wallet.fromMap(data);
    if (remoteWallet.deviceId == deviceInfo.getDeviceId()) return;

    final localWallet = await isar.wallets.get(1);
    if (localWallet == null || remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
      await isar.writeTxn(() async => await isar.wallets.put(remoteWallet));
    }
  }

  Future<void> _handleRemoteLoanChange(DocumentChange<Map<String, dynamic>> change) async {
    // Implement similar to _handleRemoteExpenseChange but for Loans
    // Note: Need to import LoanModel if not already present
  }

  Future<void> _handleRemoteSubscriptionChange(DocumentChange<Map<String, dynamic>> change) async {
    // Implement similar to _handleRemoteExpenseChange but for Subscriptions
  }

  // --- External Trigger Methods ---

  Future<void> notifyExpenseChanged(ExpenseItem item) async {
    await remoteRepo.pushExpenses([item]);
  }

  Future<void> notifyWalletChanged(Wallet wallet) async {
    await remoteRepo.pushWallet(wallet);
  }

  void dispose() {
    _expenseChangeSubscription?.cancel();
    _walletChangeSubscription?.cancel();
    _loanChangeSubscription?.cancel();
    _subscriptionChangeSubscription?.cancel();
  }
}

final syncCoordinatorProvider = FutureProvider<SyncCoordinator?>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final remoteRepo = ref.watch(cloudSyncRepositoryProvider);
  final listenerManager = ref.watch(firestoreListenerManagerProvider);
  final device = ref.watch(deviceInfoServiceProvider);

  if (remoteRepo == null || listenerManager == null) return null;

  final coordinator = SyncCoordinator(
    isar: isar,
    remoteRepo: remoteRepo,
    listenerManager: listenerManager,
    deviceInfo: device,
  );
  
  coordinator.start();
  return coordinator;
});
