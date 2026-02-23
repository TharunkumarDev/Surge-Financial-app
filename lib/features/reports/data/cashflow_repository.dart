import 'package:isar/isar.dart';
import '../../expense/domain/expense_model.dart';
import '../../auto_tracking/domain/auto_transaction.dart';
import '../../../core/utils/isar_provider.dart';

abstract class CashflowRepository {
  Future<List<ExpenseItem>> getExpenses(DateTime start, DateTime end);
  Future<List<AutoTransaction>> getAutoTransactions(DateTime start, DateTime end);
}

class IsarCashflowRepository implements CashflowRepository {
  final Isar isar;

  IsarCashflowRepository(this.isar);

  @override
  Future<List<ExpenseItem>> getExpenses(DateTime start, DateTime end) async {
    return isar.expenseItems
        .filter()
        .dateBetween(start, end)
        .findAll();
  }

  @override
  Future<List<AutoTransaction>> getAutoTransactions(DateTime start, DateTime end) async {
    return isar.autoTransactions
        .filter()
        .receivedAtBetween(start, end)
        .and()
        .isIgnoredEqualTo(false) // Filter out ignored transactions
        .findAll();
  }
}
