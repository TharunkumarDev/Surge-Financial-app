import 'package:flutter/foundation.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../subscription/domain/feature_entitlement.dart';
import '../../subscription/services/entitlement_service.dart';
import '../data/cashflow_repository.dart';
import '../domain/cashflow_report_models.dart';
import 'cashflow_calculator.dart';
import '../../expense/domain/expense_model.dart';
import '../../auto_tracking/domain/auto_transaction.dart';

class CashflowService {
  final CashflowRepository _repository;
  final EntitlementService _entitlementService;

  CashflowService(this._repository, this._entitlementService);

  Future<FullCashflowReport> generateReport({
    required SubscriptionTier tier,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Check Entitlements
    if (!_entitlementService.hasAccess(AppFeature.advancedReporting, tier)) {
      throw Exception('Upgrade to Pro to access Advanced Cashflow Reports');
    }

    // 2. Fetch Data (Parallel fetch)
    final results = await Future.wait([
      _repository.getExpenses(startDate, endDate),
      _repository.getAutoTransactions(startDate, endDate),
    ]);

    final expenses = results[0] as List<dynamic>; // Explicit cast safe due to Future.wait
    final transactions = results[1] as List<dynamic>;

    // 3. Compute Data (Off-thread for performance)
    return compute(
      _computeWrapper,
      _ComputeArgs(
        expenses: expenses.cast<ExpenseItem>(),
        transactions: transactions.cast<AutoTransaction>(),
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  // Wrapper for isolate
  static FullCashflowReport _computeWrapper(_ComputeArgs args) {
    return CashflowCalculator.calculateReport(
      expenses: args.expenses,
      transactions: args.transactions,
      startDate: args.startDate,
      endDate: args.endDate,
    );
  }
}

class _ComputeArgs {
  final List<ExpenseItem> expenses;
  final List<AutoTransaction> transactions;
  final DateTime startDate;
  final DateTime endDate;

  _ComputeArgs({
    required this.expenses,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });
}
