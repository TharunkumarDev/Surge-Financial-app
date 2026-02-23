/// LLM integration boundary for explanations and advice
/// Privacy-safe: receives only aggregated data, never raw transactions
/// 
/// PLACEHOLDER IMPLEMENTATION: Returns friendly canned responses
/// TODO: Integrate with chosen LLM provider (Gemini/OpenAI/Ollama)
class AIReasoningService {
  
  /// Generate explanation or advice based on aggregated financial data
  /// 
  /// [context] - Aggregated financial data (no PII)
  /// [query] - User's question
  /// 
  /// Returns friendly AI response
  Future<String> generateResponse({
    required Map<String, dynamic> context,
    required String query,
  }) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // PLACEHOLDER: Return canned responses based on context
    // TODO: Replace with actual LLM integration
    
    if (context.containsKey('budgetTips')) {
      return _generateBudgetTips(context);
    }
    
    if (context.containsKey('insights')) {
      return _generateInsights(context);
    }
    
    if (context.containsKey('forecast')) {
      return _generateForecast(context);
    }
    
    // Default friendly response
    return "I'm here to help you understand your finances better! "
           "I can provide insights, budget tips, and spending analysis. "
           "What would you like to know?";
  }
  
  String _generateBudgetTips(Map<String, dynamic> context) {
    final balance = context['balance'] as double?;
    final monthlySpending = context['monthlySpending'] as double?;
    
    if (balance != null && monthlySpending != null) {
      final savingsRate = balance > 0 ? (balance / (balance + monthlySpending)) * 100 : 0;
      
      if (savingsRate > 50) {
        return "Great job! You're saving over 50% of your income. "
               "Consider investing some of your savings for long-term growth. "
               "Keep up the excellent financial discipline! 💰";
      } else if (savingsRate > 20) {
        return "You're doing well with a ${savingsRate.toStringAsFixed(0)}% savings rate. "
               "To improve further, try the 50/30/20 rule: 50% needs, 30% wants, 20% savings. "
               "Look for areas where you can reduce discretionary spending. 📊";
      } else {
        return "Your current savings rate is ${savingsRate.toStringAsFixed(0)}%. "
               "Consider tracking your expenses more closely to identify areas to cut back. "
               "Start with small changes - they add up! Try reducing dining out or subscription services. 💡";
      }
    }
    
    return "To give you personalized budget tips, I need more financial data. "
           "Keep tracking your expenses and I'll provide better insights! 📈";
  }
  
  String _generateInsights(Map<String, dynamic> context) {
    final trend = context['trend'] as Map<String, dynamic>?;
    final categoryBreakdown = context['categoryBreakdown'] as Map<String, double>?;
    
    if (trend != null) {
      final changePercent = trend['changePercent'] as double;
      final trendDirection = trend['trend'] as String;
      
      if (trendDirection == 'increased' && changePercent > 20) {
        return "⚠️ Your spending has increased by ${changePercent.toStringAsFixed(0)}% compared to last month. "
               "This is a significant jump. Review your recent expenses to identify any unusual purchases. "
               "Consider setting spending alerts to stay on track.";
      } else if (trendDirection == 'decreased') {
        return "✅ Excellent! Your spending decreased by ${changePercent.abs().toStringAsFixed(0)}% this month. "
               "You're making great progress. Keep up the good habits and consider allocating the savings toward your goals.";
      }
    }
    
    if (categoryBreakdown != null && categoryBreakdown.isNotEmpty) {
      final topCategory = categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
      return "Your biggest expense category is ${topCategory.key} at ₹${topCategory.value.toStringAsFixed(2)}. "
             "This represents a significant portion of your spending. "
             "Consider if there are opportunities to optimize in this area. 🎯";
    }
    
    return "I can provide deeper insights once you have more transaction history. "
           "Keep tracking your expenses consistently! 📊";
  }
  
  String _generateForecast(Map<String, dynamic> context) {
    final monthlySpending = context['monthlySpending'] as double?;
    final balance = context['balance'] as double?;
    
    if (monthlySpending != null && balance != null && monthlySpending > 0) {
      final monthsRemaining = balance / monthlySpending;
      
      if (monthsRemaining < 1) {
        return "⚠️ At your current spending rate, your balance will run out in less than a month. "
               "Consider reducing expenses or adding income to avoid running out of funds. "
               "Focus on essential expenses only.";
      } else if (monthsRemaining < 3) {
        return "Based on your current spending pattern, your balance will last approximately "
               "${monthsRemaining.toStringAsFixed(1)} months. "
               "Consider building an emergency fund of 3-6 months of expenses for financial security. 💰";
      } else {
        return "Good news! At your current spending rate, you have approximately "
               "${monthsRemaining.toStringAsFixed(1)} months of runway. "
               "You're in a stable position. Consider investing surplus funds for growth. 📈";
      }
    }
    
    return "To provide accurate forecasts, I need more spending data. "
           "Keep tracking your expenses and check back soon! 🔮";
  }
  
  /// Check if LLM service is available
  bool isAvailable() {
    // TODO: Check actual LLM service availability
    return true; // Placeholder always returns true
  }
  
  /// Get timeout duration for LLM calls
  Duration get timeout => const Duration(seconds: 10);
}
