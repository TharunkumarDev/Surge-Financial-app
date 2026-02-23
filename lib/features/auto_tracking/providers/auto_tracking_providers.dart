import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/auto_tracking_repository.dart';
import '../data/sms_service.dart';
import '../domain/auto_transaction.dart';
import '../../subscription/services/entitlement_service.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/domain/feature_entitlement.dart';

// Persist the enabled state
final isAutoTrackingEnabledProvider = StateProvider<bool>((ref) => false); // Initialize false, load from prefs later

// Load initial state
final autoTrackingInitializerProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final isEnabled = prefs.getBool('auto_tracking_enabled') ?? false;
  ref.read(isAutoTrackingEnabledProvider.notifier).state = isEnabled;
});

// Stream of UNPROCESSED transactions
final pendingTransactionsProvider = StreamProvider<List<AutoTransaction>>((ref) async* {
  final repo = await ref.watch(autoTrackingRepositoryProvider.future);
  
  // Initial load
  yield await repo.getPendingTransactions();
  
  // In a real app, we'd watch the Isar query. 
  // For this MVP, we can rely on manual invalidation or a simple timer if needed, 
  // but let's stick to re-fetching when notified.
  // Or better, let's make the repository method return a Stream if Isar supports it (it does).
});

// Controller to handle logic
class AutoTrackingController {
  final Ref ref;

  AutoTrackingController(this.ref);

  Future<void> toggleAutoTracking(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('auto_tracking_enabled', value);
    ref.read(isAutoTrackingEnabledProvider.notifier).state = value;
    
    // Manage background service/listener
    if (value) {
       // Ideally we would start the service here if not running
       // ref.read(smsServiceProvider).startListening(); 
    } else {
       // ref.read(smsServiceProvider).stopListening();
    }
  }

  Future<void> processSms(AutoTransaction transaction) async {
    final repo = await ref.read(autoTrackingRepositoryProvider.future);
    
    // 1. Check duplicate
    if (await repo.isDuplicate(transaction.hash)) {
      return; 
    }
    
    // 2. Check entitlement 
    // ... entitlement check logic ...

    // 3. Save as pending
    await repo.saveTransaction(transaction);
    ref.invalidate(pendingTransactionsProvider); 
  }

  Future<void> syncManual() async {
    final smsService = ref.read(smsServiceProvider);
    
    // 1. Check/Request Permissions
    final hasPermission = await smsService.hasSmsPermission();
    if (!hasPermission) {
      throw Exception('SMS permission denied');
    }

    // 2. Sync from Inbox
    final transactions = await smsService.syncTransactionsFromInbox();
    final repo = await ref.read(autoTrackingRepositoryProvider.future);
    
    int newCount = 0;
    for (final tx in transactions) {
      // 3. Duplicate check before saving
      if (!await repo.isDuplicate(tx.hash)) {
        await repo.saveTransaction(tx);
        newCount++;
      }
    }

    // 4. Invalidate provider if new tx found
    if (newCount > 0) {
      ref.invalidate(pendingTransactionsProvider);
    }
  }
}

final autoTrackingControllerProvider = Provider<AutoTrackingController>((ref) {
  return AutoTrackingController(ref);
});
