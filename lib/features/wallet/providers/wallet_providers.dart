import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/isar_provider.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../auto_tracking/providers/auto_tracking_providers.dart';
import '../data/wallet_repository.dart';
import '../../../../core/services/sync_coordinator.dart';
import '../../../../core/services/device_info_service.dart';

final walletRepositoryProvider = FutureProvider<WalletRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final entitlementService = ref.watch(entitlementServiceProvider);
  final tier = ref.watch(currentSubscriptionTierProvider);
  final syncCoordinator = ref.watch(syncCoordinatorProvider).value;
  final deviceInfo = ref.watch(deviceInfoServiceProvider);
  
  return WalletRepository(
    isar: isar,
    entitlementService: entitlementService,
    currentTier: tier,
    syncCoordinator: syncCoordinator,
    deviceInfo: deviceInfo,
  );
});

final currentBalanceProvider = StreamProvider<double>((ref) async* {
  final repo = await ref.watch(walletRepositoryProvider.future);
  yield await repo.getCurrentBalance();
  yield* repo.watchBalance();
});

final currentWalletStatsProvider = StreamProvider<WalletStats>((ref) async* {
  final repo = await ref.watch(walletRepositoryProvider.future);
  yield await repo.getWalletStats();
  yield* repo.watchWalletStats();
});
