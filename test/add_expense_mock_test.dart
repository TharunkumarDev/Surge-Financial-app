import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker_pro/features/expense/data/expense_repository.dart';
import 'package:expense_tracker_pro/features/expense/domain/expense_model.dart';
import 'package:expense_tracker_pro/features/profile/providers/user_provider.dart';
import 'package:expense_tracker_pro/features/profile/domain/user_model.dart';
import 'package:expense_tracker_pro/features/auto_tracking/providers/auto_tracking_providers.dart';
import 'package:expense_tracker_pro/features/auto_tracking/domain/auto_transaction.dart';
import 'package:expense_tracker_pro/features/wallet/providers/wallet_providers.dart';
import 'package:expense_tracker_pro/features/wallet/data/wallet_repository.dart';
import 'package:expense_tracker_pro/features/home/presentation/home_screen.dart';
import 'package:expense_tracker_pro/features/expense/presentation/add_expense_screen.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:expense_tracker_pro/features/auth/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import 'package:expense_tracker_pro/core/utils/isar_provider.dart';
import 'package:expense_tracker_pro/core/providers/receipt_providers.dart';
import 'package:expense_tracker_pro/core/services/image_storage_service.dart';
import 'package:expense_tracker_pro/core/providers/currency_provider.dart';
import 'package:expense_tracker_pro/features/subscription/providers/subscription_providers.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_plan.dart';
import 'package:expense_tracker_pro/features/subscription/services/entitlement_service.dart';

class MockExpenseRepository implements ExpenseRepository {
  final _controller = StreamController<List<ExpenseItem>>.broadcast();
  final List<ExpenseItem> _items = [];

  @override get isar => throw UnimplementedError();
  @override get entitlementService => throw UnimplementedError();
  @override get currentTier => throw UnimplementedError();
  @override get currentBillCaptures => 0;
  @override get onBillCaptured => null;
  @override get syncCoordinator => null;
  @override get deviceInfo => throw UnimplementedError();

  @override
  Future<void> addExpense(ExpenseItem expense, {bool isFromScanner = false}) async {
    _items.add(expense);
    _controller.add(_items);
  }

  @override
  Stream<List<ExpenseItem>> watchExpenses() async* {
    yield _items;
    yield* _controller.stream;
  }

  @override
  Future<double> getTotalBalance() async {
    return _items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
  
  @override Future<void> deleteExpense(int id) async {}
  @override Future<List<ExpenseItem>> getAllExpenses() async => _items;
}

class MockUser extends Fake implements auth.User {
  @override String get uid => 'test_uid';
  @override String? get email => 'test@example.com';
}

class MockIsar extends Fake implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) async {
    return callback();
  }
}

class MockImageStorageService extends Fake implements ImageStorageService {}

class MockCurrencyNotifier extends StateNotifier<Currency> implements CurrencyNotifier {
  MockCurrencyNotifier() : super(Currency(code: 'USD', symbol: '\$', name: 'US Dollar'));
  
  @override
  Future<void> loadCurrency() async {}
  
  @override
  Future<void> setCurrency(Currency currency) async {
    state = currency;
  }
}

void main() {
  testWidgets('Add Expense Flow (Mocked)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    final mockRepo = MockExpenseRepository();
    final mockUser = MockUser();
    final mockIsar = MockIsar();

    final mockRouter = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add-expense',
          builder: (context, state) => const AddExpenseScreen(),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWith((ref) => Future.value(mockRepo)),
        currentUserProvider.overrideWith((ref) => Stream.value(User()..username = 'Test')),
        currentWalletStatsProvider.overrideWith((ref) => Stream.value(WalletStats(income: 0, expenses: 0, remaining: 0))),
        pendingTransactionsProvider.overrideWith((ref) => Stream.value(<AutoTransaction>[])),
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        
        isarProvider.overrideWith((ref) => Future.value(mockIsar)),
        imageStorageServiceProvider.overrideWithValue(MockImageStorageService()),
        currencyProvider.overrideWith((ref) => MockCurrencyNotifier()),
        
        // Subscription overrides to prevent Firebase initialization
        currentSubscriptionTierProvider.overrideWith((ref) => SubscriptionTier.pro),
        entitlementServiceProvider.overrideWith((ref) => EntitlementService()),
      ],
      child: MaterialApp.router(
        routerConfig: mockRouter,
        title: 'Mock App',
      ),
    ));

    // Screen size adjustment to ensure no overflow
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    
    // Explicit scroll to make sure Add Expense is visible
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, "99.00");
    await tester.enterText(find.byType(TextField).at(1), "Groceries");
    await tester.tap(find.text("Save Transaction"));
    await tester.pumpAndSettle();

    expect(find.text("Groceries"), findsOneWidget, reason: "Expense title should be visible");
  });
}
