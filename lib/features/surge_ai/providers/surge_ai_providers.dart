import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/isar_provider.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../../expense/data/expense_repository.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/finance_intent.dart';
import '../services/finance_data_provider.dart';
import '../services/intent_classifier.dart';
import '../services/ai_reasoning_service.dart';
import '../services/surge_ai_controller.dart';
import '../services/finance_insight_engine.dart';
import '../services/balance_forecast_service.dart';
import '../services/backend_ai_service.dart';

// Backend AI Service Provider
final backendAIServiceProvider = Provider<BackendAIService>((ref) {
  return BackendAIService(
    auth: FirebaseAuth.instance,
    // Using host machine's IP address for emulator access
    // Alternative: use 10.0.2.2 for standard Android emulator
    // For production, use your deployed backend URL
    baseUrl: 'http://192.168.60.195:3000/api/v1/surge-ai',
  );
});

// Chat Repository Provider
final chatRepositoryProvider = FutureProvider<ChatRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ChatRepository(isar: isar);
});

// Finance Data Provider
final financeDataProviderProvider = FutureProvider<FinanceDataProvider>((ref) async {
  final walletRepo = await ref.watch(walletRepositoryProvider.future);
  final expenseRepo = await ref.watch(expenseRepositoryProvider.future);
  
  return FinanceDataProvider(
    walletRepository: walletRepo,
    expenseRepository: expenseRepo,
  );
});

// Intent Classifier Provider
final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  return IntentClassifier();
});

// AI Reasoning Service Provider
final aiReasoningServiceProvider = Provider<AIReasoningService>((ref) {
  return AIReasoningService();
});

// Finance Insight Engine Provider (F2)
final financeInsightEngineProvider = Provider<FinanceInsightEngine>((ref) {
  return FinanceInsightEngine();
});

// Balance Forecast Service Provider (F4)
final balanceForecastServiceProvider = Provider<BalanceForecastService>((ref) {
  return BalanceForecastService();
});

// Daily AI Chat Count Provider (from subscription)
final dailyAIChatCountProvider = Provider<int>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider).value;
  return subscription?.dailyAIChatCount ?? 0;
});

// Surge AI Controller Provider
final surgeAIControllerProvider = FutureProvider<SurgeAIController>((ref) async {
  final financeDataProvider = await ref.watch(financeDataProviderProvider.future);
  final intentClassifier = ref.watch(intentClassifierProvider);
  final aiReasoningService = ref.watch(aiReasoningServiceProvider);
  final financeInsightEngine = ref.watch(financeInsightEngineProvider);
  final balanceForecastService = ref.watch(balanceForecastServiceProvider);
  final backendAIService = ref.watch(backendAIServiceProvider);
  final currentTier = ref.watch(currentSubscriptionTierProvider);
  final dailyCount = ref.watch(dailyAIChatCountProvider);
  
  return SurgeAIController(
    financeDataProvider: financeDataProvider,
    intentClassifier: intentClassifier,
    aiReasoningService: aiReasoningService,
    financeInsightEngine: financeInsightEngine,
    balanceForecastService: balanceForecastService,
    backendAIService: backendAIService,
    currentTier: currentTier,
    dailyAIChatCount: dailyCount,
  );
});

// Chat Messages Stream Provider
final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) async* {
  final chatRepo = await ref.watch(chatRepositoryProvider.future);
  yield* chatRepo.watchMessages(limit: 50);
});

// Quick Suggestions Provider
final quickSuggestionsProvider = Provider<List<QuickSuggestion>>((ref) {
  return QuickSuggestion.defaults;
});

// AI Loading State Provider
final aiLoadingStateProvider = StateProvider<bool>((ref) => false);

// Chat Input Controller Provider
final chatInputControllerProvider = StateProvider<String>((ref) => '');
