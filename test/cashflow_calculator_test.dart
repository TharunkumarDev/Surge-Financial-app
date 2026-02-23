import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_pro/features/reports/application/cashflow_calculator.dart';
import 'package:expense_tracker_pro/features/expense/domain/expense_model.dart';
import 'package:expense_tracker_pro/features/auto_tracking/domain/auto_transaction.dart';

void main() {
  test('CashflowCalculator aggregates data correctly', () {
    // Setup Data
    final date = DateTime(2025, 2, 1);
    
    // 1. Expenses (Manual Debits)
    final expenses = [
      ExpenseItem()
        ..amount = 100
        ..category = ExpenseCategory.food
        ..date = date
        ..isRecurring = false,
      ExpenseItem()
        ..amount = 50
        ..category = ExpenseCategory.transport
        ..date = date.add(const Duration(days: 1))
        ..isRecurring = false,
    ];
    
    // 2. Transactions (Credits & Debits)
    final transactions = [
      // Credit: Salary
      AutoTransaction(
        hash: '1', 
        originalSmsBody: 'Credited 5000', 
        senderId: 'ACME', 
        receivedAt: date,
        type: TransactionType.credit,
        amount: 5000,
        merchantName: 'Work',
      ),
      // Debit: UPI Payment (Should be used for UPI stats, but not general cashflow sum if expenses used?)
      // Calculator logic: "Debit transactions from transactions list are used for UPI stats"
      AutoTransaction(
        hash: '2',
        originalSmsBody: 'Sent 200',
        senderId: 'UPI',
        receivedAt: date.add(const Duration(days: 2)),
        type: TransactionType.debit,
        amount: 200,
        merchantName: 'Friend',
      ),
    ];
    
    // Run Calculator
    final report = CashflowCalculator.calculateReport(
      expenses: expenses,
      transactions: transactions,
      startDate: DateTime(2025, 2, 1),
      endDate: DateTime(2025, 2, 28),
    );
    
    // Verify Monthly Summary
    // Sent: 100 + 50 = 150 (From Expenses)
    // Received: 5000 (From Credits)
    expect(report.monthlySummary.totalSent, 150.0);
    expect(report.monthlySummary.totalReceived, 5000.0);
    expect(report.monthlySummary.netCashflow, 4850.0);
    
    // Verify Categories
    expect(report.expenseCategories.length, 2);
    expect(report.expenseCategories.first.categoryName, 'food');
    expect(report.expenseCategories.first.totalAmount, 100.0);
    
    // Verify Income Sources
    expect(report.incomeSources.length, 1);
    expect(report.incomeSources.first.categoryName, 'ACME'); // SenderId takes precedence
    
    // Verify UPI Stats
    // Top Receivers (We sent money TO): 'Friend' (from AutoDebit)
    expect(report.topReceivers.length, 1);
    expect(report.topReceivers.first.name, 'Friend');
    expect(report.topReceivers.first.totalAmount, 200.0);
    
    // Top Senders (We received FROM): 'ACME'
    expect(report.topSenders.length, 1);
    expect(report.topSenders.first.name, 'ACME');
    
    // Verify Advanced Metrics
    // Days filtered: 28 days (Feb 1 to 28)
    // Avg Daily Income = 5000 / 28
    expect(report.advancedMetrics.averageDailyIncome, closeTo(5000/28, 0.01));
    // Savings Rate = (5000 - 150) / 5000 * 100 = 97%
    expect(report.advancedMetrics.savingsRate, 97.0);
  });
}
