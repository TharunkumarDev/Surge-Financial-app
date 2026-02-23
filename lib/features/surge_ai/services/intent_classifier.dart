import '../domain/finance_intent.dart';

/// Local intent classification engine
/// Fast pattern matching for common finance queries without external API calls
class IntentClassifier {
  
  /// Classify user query into finance intent
  IntentResult classify(String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    // Balance queries
    if (_matchesKeywords(lowerQuery, ['balance', 'remaining', 'left', 'have'])) {
      return IntentResult(
        intent: FinanceIntent.balance,
        confidence: 0.9,
        parameters: {},
      );
    }
    
    // Monthly spending queries
    if (_matchesKeywords(lowerQuery, ['month', 'monthly']) && 
        _matchesKeywords(lowerQuery, ['spend', 'spent', 'expense'])) {
      return IntentResult(
        intent: FinanceIntent.monthlySpending,
        confidence: 0.85,
        parameters: {},
      );
    }
    
    // Weekly spending queries
    if (_matchesKeywords(lowerQuery, ['week', 'weekly']) && 
        _matchesKeywords(lowerQuery, ['spend', 'spent', 'expense'])) {
      return IntentResult(
        intent: FinanceIntent.weeklySpending,
        confidence: 0.85,
        parameters: {},
      );
    }
    
    // Category breakdown queries / "Where did my money go?"
    if (_matchesKeywords(lowerQuery, ['category', 'categories', 'breakdown', 'where']) ||
        _matchesKeywords(lowerQuery, ['where did', 'where my money'])) {
      return IntentResult(
        intent: FinanceIntent.categoryExpenses,
        confidence: 0.85,
        parameters: {},
      );
    }
    
    // Recent transactions queries
    if (_matchesKeywords(lowerQuery, ['recent', 'last', 'latest']) && 
        _matchesKeywords(lowerQuery, ['transaction', 'expense', 'purchase'])) {
      return IntentResult(
        intent: FinanceIntent.recentTransactions,
        confidence: 0.85,
        parameters: {},
      );
    }
    
    // Budget tips queries
    if (_matchesKeywords(lowerQuery, ['budget', 'save', 'saving', 'tip'])) {
      return IntentResult(
        intent: FinanceIntent.budgetTips,
        confidence: 0.8,
        parameters: {},
      );
    }
    
    // Insights queries
    if (_matchesKeywords(lowerQuery, ['insight', 'analysis', 'pattern', 'trend'])) {
      return IntentResult(
        intent: FinanceIntent.insights,
        confidence: 0.8,
        parameters: {},
      );
    }
    
    // Forecast queries
    if (_matchesKeywords(lowerQuery, ['forecast', 'predict', 'future', 'next month', 'end of month', 'month end'])) {
      return IntentResult(
        intent: FinanceIntent.forecast,
        confidence: 0.85,
        parameters: {},
      );
    }
    
    // General finance questions
    if (_matchesKeywords(lowerQuery, ['money', 'finance', 'financial'])) {
      return IntentResult(
        intent: FinanceIntent.general,
        confidence: 0.6,
        parameters: {},
      );
    }
    
    // Unknown intent
    return IntentResult(
      intent: FinanceIntent.unknown,
      confidence: 0.3,
      parameters: {},
    );
  }
  
  /// Check if query contains any of the keywords
  bool _matchesKeywords(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }
  
  /// Extract number from query (e.g., "last 5 transactions")
  int? extractNumber(String query) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(query);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }
}
