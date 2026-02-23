import 'package:isar/isar.dart';
import '../../subscription/domain/feature_entitlement.dart';
import '../../subscription/services/entitlement_service.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../domain/wallet_model.dart';
import '../../expense/domain/expense_model.dart';
import '../../../core/services/sync_coordinator.dart';
import '../../../core/services/device_info_service.dart';
import 'package:async/async.dart';

class InsufficientPermissionException implements Exception {
  final String featureName;
  final SubscriptionTier minimumTier;

  InsufficientPermissionException({
    required this.featureName,
    required this.minimumTier,
  });

  @override
  String toString() => 'Insufficient Permission: $featureName requires $minimumTier plan';
}

class WalletStats {
  final double income;
  final double expenses;
  final double remaining;

  WalletStats({
    required this.income,
    required this.expenses,
    required this.remaining,
  });
  
  double get savingsPercentage {
    if (income <= 0) return 0.0;
    return (remaining / income) * 100;
  }
}

class WalletRepository {
  final Isar isar;
  final EntitlementService entitlementService;
  final SubscriptionTier currentTier;
  final SyncCoordinator? syncCoordinator;
  final DeviceInfoService deviceInfo;
  
  WalletRepository({
    required this.isar,
    required this.entitlementService,
    required this.currentTier,
    this.syncCoordinator,
    required this.deviceInfo,
  });
  
  Future<Wallet> getWallet() async {
    var wallet = await isar.wallets.get(1);
    if (wallet == null) {
      wallet = Wallet.create(
        initialBalance: 0.0,
        deviceId: deviceInfo.getDeviceId(),
      );
      await isar.writeTxn(() async {
        await isar.wallets.put(wallet!);
      });
    }
    return wallet;
  }
  
  Future<void> setInitialBalance(double amount) async {
    // Check entitlement
    if (!entitlementService.hasAccess(AppFeature.addWallet, currentTier)) {
      throw InsufficientPermissionException(
        featureName: 'Setting Wallet Balance',
        minimumTier: SubscriptionTier.basic,
      );
    }

    var wallet = await getWallet();
    wallet.initialBalance = amount;
    wallet.lastUpdated = DateTime.now();
    wallet.updatedAt = DateTime.now();
    wallet.deviceId = deviceInfo.getDeviceId();

    await isar.writeTxn(() async {
      await isar.wallets.put(wallet);
    });
    
    // Sync to Cloud via Coordinator
    await syncCoordinator?.notifyWalletChanged(wallet);
  }
  
  Future<double> getCurrentBalance() async {
    final wallet = await getWallet();
    final expenses = await isar.expenseItems.where().findAll();
    final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    return wallet.initialBalance - totalExpenses;
  }
  
  Future<WalletStats> getWalletStats() async {
    final wallet = await getWallet();
    final expenses = await isar.expenseItems.where().findAll();
    final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    
    return WalletStats(
      income: wallet.initialBalance,
      expenses: totalExpenses,
      remaining: wallet.initialBalance - totalExpenses,
    );
  }
  
  Stream<double> watchBalance() async* {
    // Initial emission
    yield await getCurrentBalance();
    
    // Merge streams: wallet updates AND expense updates
    final walletStream = isar.wallets.watchObjectLazy(1);
    final expensesStream = isar.expenseItems.watchLazy();
    
    await for (final _ in StreamGroup.merge([walletStream, expensesStream])) {
      yield await getCurrentBalance();
    }
  }

  Stream<WalletStats> watchWalletStats() async* {
    yield await getWalletStats();
    
    final walletStream = isar.wallets.watchObjectLazy(1);
    final expensesStream = isar.expenseItems.watchLazy();
    
    await for (final _ in StreamGroup.merge([walletStream, expensesStream])) {
      yield await getWalletStats();
    }
  }

  Future<void> clearBalance({bool clearSalary = true, bool clearExpenses = true}) async {
    await isar.writeTxn(() async {
      if (clearSalary) {
        final wallet = await isar.wallets.get(1);
        if (wallet != null) {
          wallet.initialBalance = 0;
          wallet.updatedAt = DateTime.now();
          await isar.wallets.put(wallet);
        }
      }
      if (clearExpenses) {
        await isar.expenseItems.where().deleteAll();
      }
    });
    
    // TODO: Coordinate mass changes
  }
}
