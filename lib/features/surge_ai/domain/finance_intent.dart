enum FinanceIntent {
  balance,
  monthlySpending,
  weeklySpending,
  categoryExpenses,
  recentTransactions,
  budgetTips,
  insights,
  forecast,
  general,
  unknown,
}

class IntentResult {
  final FinanceIntent intent;
  final double confidence;
  final Map<String, dynamic> parameters;
  
  IntentResult({
    required this.intent,
    required this.confidence,
    this.parameters = const {},
  });
  
  bool get isConfident => confidence > 0.7;
}

class QuickSuggestion {
  final String label;
  final String query;
  final bool requiresPro;
  final FinanceIntent intent;
  
  const QuickSuggestion({
    required this.label,
    required this.query,
    this.requiresPro = false,
    required this.intent,
  });
  
  static const List<QuickSuggestion> defaults = [
    QuickSuggestion(
      label: 'Current balance',
      query: 'What is my current balance?',
      intent: FinanceIntent.balance,
    ),
    QuickSuggestion(
      label: 'This month spending',
      query: 'How much did I spend this month?',
      intent: FinanceIntent.monthlySpending,
    ),
    QuickSuggestion(
      label: 'Recent transactions',
      query: 'Show me my recent transactions',
      intent: FinanceIntent.recentTransactions,
    ),
    QuickSuggestion(
      label: 'Budget tips',
      query: 'Give me budget tips',
      requiresPro: true,
      intent: FinanceIntent.budgetTips,
    ),
  ];
}
