
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/credit_health_score.dart';
import '../../domain/repositories/credit_health_repository.dart';
import '../../data/repositories/credit_health_repository_impl.dart';
import '../../data/datasources/credit_scoring_engine.dart';
import '../../domain/services/ai_credit_explainer.dart';
import '../../../expense/data/expense_repository.dart';
import '../../../subscription/providers/subscription_providers.dart'; // Assuming this exists or similar
import '../../../wallet/providers/wallet_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../surge_ai/services/ai_reasoning_service.dart';

// 1. Data Source Providers
final creditScoringEngineProvider = Provider<CreditScoringEngine>((ref) {
  return CreditScoringEngine();
});

final aiCreditExplainerProvider = Provider<AICreditExplainer>((ref) {
  // Assuming AIReasoningService is available via a provider or singleton
  // For now, we instantiate directly or fetch if a provider exists.
  // Finding existing provider... likely aiReasoningServiceProvider
  return AICreditExplainer(AIReasoningService()); 
});


// 2. Repository Provider
// 2. Repository Provider (Must be FutureProvider because walletRepositoryProvider is FutureProvider)
final creditHealthRepositoryProvider = FutureProvider<CreditHealthRepository>((ref) async {
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  final subRepo = ref.watch(subscriptionRepositoryProvider);
  final walletRepo = await ref.watch(walletRepositoryProvider.future);
  final user = await ref.watch(authStateProvider.future);
  final engine = ref.watch(creditScoringEngineProvider);
  final aiExplainer = ref.watch(aiCreditExplainerProvider);
  final firestore = ref.watch(firestoreProvider);

  return CreditHealthRepositoryImpl(
    expenseRepo: expenseRepo,
    subRepo: subRepo,
    walletRepo: walletRepo,
    engine: engine,
    aiExplainer: aiExplainer,
    firestore: firestore,
    userId: user?.uid ?? '',
  );
});

// 3. Logic/State Provider
final creditHealthScoreProvider = FutureProvider<CreditHealthScore>((ref) async {
  final repo = await ref.watch(creditHealthRepositoryProvider.future);
  return repo.calculateCreditHealth();
});

final creditHealthHistoryProvider = FutureProvider<List<CreditHealthScore>>((ref) async {
  final repo = await ref.watch(creditHealthRepositoryProvider.future);
  return repo.getScoreHistory();
});
