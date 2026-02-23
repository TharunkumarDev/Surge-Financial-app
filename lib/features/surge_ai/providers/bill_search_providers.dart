import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bill_search_service.dart';
import '../../expense/data/expense_repository.dart';
import '../../expense/data/bill_image_repository.dart';

/// Provider for BillSearchService
final billSearchServiceProvider = Provider<BillSearchService>((ref) {
  // Note: These are FutureProviders, so we need to handle async
  throw UnimplementedError('Use billSearchServiceFutureProvider instead');
});

/// Async provider for BillSearchService
final billSearchServiceFutureProvider = FutureProvider<BillSearchService>((ref) async {
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  final billImageRepo = await ref.watch(billImageRepositoryProvider.future);
  
  return BillSearchService(
    expenseRepository: expenseRepo,
    billImageRepository: billImageRepo,
  );
});
