import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import '../../../core/utils/isar_provider.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../data/cashflow_repository.dart';
import '../../expense/domain/expense_model.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
// Actually I put the impl in the same file `reports/data/cashflow_repository.dart`?
// Let me check. I put it in `lib/features/reports/data/cashflow_repository.dart`.
// So I need to export or modify imports.
import '../application/cashflow_service.dart';
import '../domain/cashflow_report_models.dart';
import 'package:equatable/equatable.dart';

// Update: I defined `IsarCashflowRepository` in `cashflow_repository.dart`
// so I just import that.

// 1. Repository Provider
final cashflowRepositoryProvider = Provider<CashflowRepository>((ref) {
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar == null) throw UnimplementedError('Isar not initialized');
  return IsarCashflowRepository(isar);
});

// 2. Service Provider
final cashflowServiceProvider = Provider<CashflowService>((ref) {
  final repo = ref.watch(cashflowRepositoryProvider);
  final entitlement = ref.watch(entitlementServiceProvider);
  return CashflowService(repo, entitlement);
});

// 3. Date Range Parameter
class ReportDateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const ReportDateRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

// 4. Reactive Report Provider
final cashflowReportProvider = FutureProvider.family<FullCashflowReport, ReportDateRange>((ref, range) async {
  final service = ref.watch(cashflowServiceProvider);
  final tier = ref.watch(currentSubscriptionTierProvider);
  
  // Watch for Database Changes (Reactivity)
  // We use stream providers to trigger rebuilds
  // This is a simplified "invalidator" pattern
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar != null) {
    // Watch relevant collections
    final expensesStream = isar.expenseItems.watchLazy();
    final autoStream = isar.autoTransactions.watchLazy();
    
    // Subscribe to changes (this will cause the provider to re-execute when streams fire)
    // However, FutureProvider doesn't standardly accept streams like this directly without internal stream subscription.
    // Better pattern: Use StreamProvider or 'ref.watch(streamProvider)'
    
    // We bind the invalidation to an external stream provider?
    // Or just fetch data.
    // For "Recalculate on new data", valid approach:
    // ref.watch(transactionChangeProvider);
  }
  
  return service.generateReport(
    tier: tier,
    startDate: range.start,
    endDate: range.end,
  );
});

// 5. Invalidator (Optional, but cleaner)
final transactionChangeStreamProvider = StreamProvider<void>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* StreamGroup.merge([
    isar.expenseItems.watchLazy(),
    isar.autoTransactions.watchLazy(),
  ]);
});

// Updated Provider using Invalidator
final liveCashflowReportProvider = FutureProvider.family<FullCashflowReport, ReportDateRange>((ref, range) async {
  // Dependency: trigger rebuild on db change
  ref.watch(transactionChangeStreamProvider);
  
  final service = ref.watch(cashflowServiceProvider);
  final tier = ref.watch(currentSubscriptionTierProvider);
  
  return service.generateReport(
    tier: tier,
    startDate: range.start,
    endDate: range.end,
  );
});
