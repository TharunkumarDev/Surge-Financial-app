import '../domain/finance_intent.dart';
import '../domain/chat_message.dart';
import '../domain/balance_forecast.dart';

import 'finance_data_provider.dart';
import 'intent_classifier.dart';
import 'ai_reasoning_service.dart';
import 'finance_insight_engine.dart';
import 'balance_forecast_service.dart';
import 'backend_ai_service.dart';
import '../../subscription/domain/subscription_plan.dart';

/// Main AI orchestration controller
/// Routes queries through intent classifier and appropriate response layer
class SurgeAIController {
  final FinanceDataProvider financeDataProvider;
  final IntentClassifier intentClassifier;
  final AIReasoningService aiReasoningService;
  final FinanceInsightEngine financeInsightEngine;
  final BalanceForecastService balanceForecastService;
  final BackendAIService backendAIService;
  final SubscriptionTier currentTier;
  final int dailyAIChatCount;
  
  SurgeAIController({
    required this.financeDataProvider,
    required this.intentClassifier,
    required this.aiReasoningService,
    required this.financeInsightEngine,
    required this.balanceForecastService,
    required this.backendAIService,
    required this.currentTier,
    required this.dailyAIChatCount,
  });
  
  /// Process user query and generate AI response
  Future<ChatMessage> processQuery(String query) async {
    try {
      // Check usage limits
      if (!_canUseAIChat()) {
        return ChatMessage.ai(
          "You've reached your daily limit of 5 AI chats on the free plan. "
          "Upgrade to Pro for unlimited AI conversations and advanced insights! 🚀",
        );
      }
      
      // Classify intent
      final intentResult = intentClassifier.classify(query);
      
      // Route to appropriate handler
      if (intentResult.isConfident) {
        return await _handleStructuredIntent(intentResult, query);
      } else {
        return await _handleGeneralQuery(query);
      }
    } catch (e) {
      return ChatMessage.ai(
        "I encountered an error processing your request. Please try again. "
        "If the problem persists, contact support.",
      );
    }
  }
  
  /// Handle structured finance intents with local data
  Future<ChatMessage> _handleStructuredIntent(IntentResult intent, String query) async {
    switch (intent.intent) {
      case FinanceIntent.balance:
        return await _handleBalanceQuery();
      
      case FinanceIntent.monthlySpending:
        return await _handleMonthlySpendingQuery();
      
      case FinanceIntent.weeklySpending:
        return await _handleWeeklySpendingQuery();
      
      case FinanceIntent.categoryExpenses:
        return await _handleCategoryQuery();
      
      case FinanceIntent.recentTransactions:
        return await _handleRecentTransactionsQuery();
      
      case FinanceIntent.budgetTips:
        return await _handleBudgetTipsQuery();
      
      case FinanceIntent.insights:
        return await _handleInsightsQuery();
      
      case FinanceIntent.forecast:
        return await _handleForecastQuery();
      
      default:
        return await _handleGeneralQuery(query);
    }
  }
  
  Future<ChatMessage> _handleBalanceQuery() async {
    final balance = await financeDataProvider.getCurrentBalance();
    final formatted = financeDataProvider.formatCurrency(balance);
    
    return ChatMessage.ai(
      "Your current balance is $formatted. "
      "${balance > 0 ? "You're in good shape! 💰" : "Consider adding funds or reducing expenses. 📊"}",
    );
  }
  
  Future<ChatMessage> _handleMonthlySpendingQuery() async {
    final spending = await financeDataProvider.getMonthlySpending();
    final formatted = financeDataProvider.formatCurrency(spending);
    
    return ChatMessage.ai(
      "You've spent $formatted this month. "
      "Would you like to see a category breakdown or compare with last month?",
    );
  }
  
  Future<ChatMessage> _handleWeeklySpendingQuery() async {
    final spending = await financeDataProvider.getWeeklySpending();
    final formatted = financeDataProvider.formatCurrency(spending);
    
    return ChatMessage.ai(
      "You've spent $formatted this week. "
      "Keep tracking to stay on budget! 📈",
    );
  }
  
  Future<ChatMessage> _handleCategoryQuery() async {
    // Use new FinanceInsightEngine for detailed spending explanation
    final expenses = await financeDataProvider.getExpenses();
    
    final insight = await financeInsightEngine.generateMonthlySpendingExplanation(
      expenses: expenses,
    );
    
    if (insight.categoryBreakdown.isEmpty) {
      return ChatMessage.ai(
        "You don't have any expenses recorded yet. "
        "Start tracking your expenses to see category breakdowns! 📊",
      );
    }
    
    // Return the AI-generated explanation
    return ChatMessage.ai(insight.explanation);
  }
  
  Future<ChatMessage> _handleRecentTransactionsQuery() async {
    final summary = await financeDataProvider.getRecentTransactionsSummary(limit: 5);
    final count = summary['count'] as int;
    final total = summary['total'] as double;
    final average = summary['average'] as double;
    
    if (count == 0) {
      return ChatMessage.ai(
        "You don't have any recent transactions. "
        "Start tracking your expenses! 📝",
      );
    }
    
    return ChatMessage.ai(
      "Your last $count transactions:\n"
      "Total: ${financeDataProvider.formatCurrency(total)}\n"
      "Average: ${financeDataProvider.formatCurrency(average)}\n\n"
      "Keep tracking to build better spending habits! 💡",
    );
  }
  
  Future<ChatMessage> _handleBudgetTipsQuery() async {
    if (!_canAccessProFeatures()) {
      return ChatMessage.ai(
        "Budget tips and personalized advice are available with Pro! "
        "Upgrade to get AI-powered financial insights and recommendations. 🚀",
      );
    }
    
    final balance = await financeDataProvider.getCurrentBalance();
    final monthlySpending = await financeDataProvider.getMonthlySpending();
    
    final context = {
      'budgetTips': true,
      'balance': balance,
      'monthlySpending': monthlySpending,
    };
    
    final response = await aiReasoningService.generateResponse(
      context: context,
      query: 'budget tips',
    );
    
    return ChatMessage.ai(response);
  }
  
  Future<ChatMessage> _handleInsightsQuery() async {
    if (!_canAccessProFeatures()) {
      return ChatMessage.ai(
        "Advanced insights are a Pro feature! "
        "Upgrade to unlock spending analysis, trends, and personalized recommendations. 📊",
      );
    }
    
    final trend = await financeDataProvider.getSpendingTrend();
    final categoryBreakdown = await financeDataProvider.getCategoryBreakdown();
    
    final context = {
      'insights': true,
      'trend': trend,
      'categoryBreakdown': categoryBreakdown,
    };
    
    final response = await aiReasoningService.generateResponse(
      context: context,
      query: 'insights',
    );
    
    return ChatMessage.ai(response);
  }
  
  Future<ChatMessage> _handleForecastQuery() async {
    if (!_canAccessProFeatures()) {
      return ChatMessage.ai(
        "Financial forecasting is a Pro feature! "
        "Upgrade to get predictions and planning tools. 🔮",
      );
    }
    
    // Use new BalanceForecastService for accurate predictions
    final expenses = await financeDataProvider.getExpenses();
    final currentBalance = await financeDataProvider.getBalance();
    
    final forecast = await balanceForecastService.calculateMonthEndForecast(
      expenses: expenses,
      currentBalance: currentBalance,
    );
    
    // Build response with forecast data
    final response = StringBuffer();
    response.write('${forecast.riskLevel.emoji} ');
    response.write(forecast.explanation);
    
    if (forecast.recommendation != null) {
      response.write('\n\n💡 ');
      response.write(forecast.recommendation);
    }
    
    return ChatMessage.ai(response.toString());
  }
  
  Future<ChatMessage> _handleGeneralQuery(String query) async {
    // Try backend AI first (OpenAI GPT-4o mini), fall back to local AI if unavailable
    try {
      print('🔵 Attempting backend AI connection...');
      
      // Quick timeout to fail fast if backend unavailable
      final response = await backendAIService.sendMessage(
        message: query,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Backend timeout - using local AI');
          throw BackendAIException('Connection timeout');
        },
      );
      
      print('✅ Backend AI response received');
      return ChatMessage.ai(response.reply);
      
    } on RateLimitException catch (e) {
      print('⚠️ Rate limit - showing upgrade prompt');
      return ChatMessage.ai(e.message);
      
    } catch (e) {
      // Graceful fallback to local AI for ANY error
      print('💡 Backend unavailable, using local AI: ${e.toString().split('\n').first}');
      
      // Generate smart local response based on query
      return _generateLocalResponse(query);
    }
  }
  
  ChatMessage _generateLocalResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Friendly responses for common queries
    if (lowerQuery.contains('hi') || lowerQuery.contains('hello') || lowerQuery.contains('hey')) {
      return ChatMessage.ai(
        "Hi! 👋 I'm your Surge AI assistant. I can help you understand your finances, track spending, and provide budget insights. What would you like to know?"
      );
    }
    
    if (lowerQuery.contains('help') || lowerQuery.contains('what can you do')) {
      return ChatMessage.ai(
        "I can help you with:\n\n"
        "💰 Current balance and spending\n"
        "📊 Monthly financial insights\n"
        "🎯 Budget recommendations\n"
        "📈 Spending forecasts\n\n"
        "Try asking about your balance or this month's spending!"
      );
    }
    
    if (lowerQuery.contains('thank')) {
      return ChatMessage.ai("You're welcome! Let me know if you need anything else. 😊");
    }
    
    // Default helpful response
    return ChatMessage.ai(
      "I'm here to help with your finances! Try asking me about:\n\n"
      "• Your current balance\n"
      "• This month's spending\n"
      "• Recent transactions\n"
      "• Budget recommendations\n\n"
      "What would you like to know?"
    );
  }
  
  bool _canUseAIChat() {
    if (currentTier == SubscriptionTier.pro) return true;
    return dailyAIChatCount < 5; // Free tier limit
  }
  
  bool _canAccessProFeatures() {
    return currentTier == SubscriptionTier.pro;
  }
}
