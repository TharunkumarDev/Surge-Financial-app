import 'package:isar/isar.dart' as isar_lib;
import 'package:isar/isar.dart'; // Keep original for generated part file compatibility? Or replace usage.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/isar_provider.dart';
import '../../subscription/domain/feature_entitlement.dart';
import '../../subscription/services/entitlement_service.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../wallet/data/wallet_repository.dart'; // For InsufficientPermissionException
import '../domain/expense_model.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/services/sync_coordinator.dart';
import '../../../core/services/device_info_service.dart';
import 'bill_image_repository.dart';

part 'expense_repository.g.dart';

class ExpenseRepository {
  final isar_lib.Isar isar;
  final EntitlementService entitlementService;
  final SubscriptionTier currentTier;
  final int currentBillCaptures;
  final Function(bool isScanner)? onBillCaptured;
  final SyncCoordinator? syncCoordinator;
  final DeviceInfoService deviceInfo;
  final BillImageRepository billImageRepository;

  ExpenseRepository({
    required this.isar,
    required this.entitlementService,
    required this.currentTier,
    required this.currentBillCaptures,
    required this.billImageRepository,
    this.onBillCaptured,
    this.syncCoordinator,
    required this.deviceInfo,
  });

  Future<void> addExpense(ExpenseItem expense, {bool isFromScanner = false}) async {
    // Check general add expense entitlement
    if (!entitlementService.hasAccess(AppFeature.addExpense, currentTier)) {
      throw InsufficientPermissionException(
        featureName: 'Adding Expense',
        minimumTier: SubscriptionTier.basic,
      );
    }

    // Check bill capture limit if from scanner
    if (isFromScanner) {
      if (!entitlementService.canCaptureBill(currentTier, currentBillCaptures)) {
        throw InsufficientPermissionException(
          featureName: 'Bill Capture Limit reached',
          minimumTier: SubscriptionTier.pro, // Suggest upgrade to Pro for unlimited
        );
      }
      // Notify repository to increment counter (handled via callback)
      onBillCaptured?.call(true);
    }

    // Set sync metadata
    expense.createdAt = DateTime.now();
    expense.updatedAt ??= DateTime.now();
    expense.deviceId = deviceInfo.getDeviceId();

    await isar.writeTxn(() async {
      await isar.collection<ExpenseItem>().put(expense);
    });
    
    // Sync to Cloud via Coordinator
    await syncCoordinator?.notifyExpenseChanged(expense);
  }

  Future<void> deleteExpense(int id) async {
    // NOTE: For real-time sync with deletes, we usually need "Soft Deletes"
    // or to push the delete event to Firestore. 
    // Here we'll delete locally and let the Firestore listener handle it if we had a tombstone system,
    // but for now we'll just delete from Firestore directly.
    
    // First delete associated bill images
    await billImageRepository.deleteBillImagesByExpenseId(id);
    
    await isar.writeTxn(() async {
      await isar.collection<ExpenseItem>().delete(id);
    });
    
    // TODO: Direct Firestore delete could be handled by coordinator
  }

  Future<List<ExpenseItem>> getAllExpenses() async {
    return await isar.collection<ExpenseItem>().where().sortByDateDesc().findAll();
  }

  Stream<List<ExpenseItem>> watchExpenses() {
    return isar.collection<ExpenseItem>().where().sortByDateDesc().watch(fireImmediately: true);
  }

  Future<double> getTotalBalance() async {
    final expenses = await isar.collection<ExpenseItem>().where().findAll();
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}

@riverpod
Future<ExpenseRepository> expenseRepository(ExpenseRepositoryRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  final entitlementService = ref.watch(entitlementServiceProvider);
  final subscription = ref.watch(currentSubscriptionProvider).value;
  final tier = subscription?.tier ?? SubscriptionTier.free;
  final captures = subscription?.billCapturesThisMonth ?? 0;
  
  final authUser = ref.watch(currentAuthUserProvider).value;
  final syncCoordinator = ref.watch(syncCoordinatorProvider).value;
  final deviceInfo = ref.watch(deviceInfoServiceProvider);
  final billImageRepository = await ref.watch(billImageRepositoryProvider.future);

  return ExpenseRepository(
    isar: isar,
    entitlementService: entitlementService,
    currentTier: tier,
    currentBillCaptures: captures,
    billImageRepository: billImageRepository,
    syncCoordinator: syncCoordinator,
    deviceInfo: deviceInfo,
    onBillCaptured: (isScanner) {
      if (isScanner && authUser != null) {
        ref.read(subscriptionRepositoryProvider).incrementBillCapture(authUser.uid);
      }
    },
  );
}
