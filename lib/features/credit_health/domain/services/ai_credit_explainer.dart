
import '../entities/credit_health_score.dart';
import '../../../surge_ai/services/ai_reasoning_service.dart';

class AICreditExplainer {
  final AIReasoningService _aiService;

  AICreditExplainer(this._aiService);

  Future<String> generateExplanation(CreditHealthScore score) async {
    // Construct a prompt based on the deterministic factors
    final prompt = _buildPrompt(score);
    
    // Call Surge AI (Mocked for now via existing service pattern)
    // The existing AIReasoningService has canned responses, so we might need to 
    // extend it or just use it as is for now.
    
    // Since AIReasoningService.generateResponse takes a map context, we'll adapt:
    return await _aiService.generateResponse(
      context: {
        'creditScore': score.score,
        'category': score.category.name,
        'paymentPunctuality': score.paymentPunctuality,
        'creditUtilization': score.creditUtilization,
        'savingsHealth': score.savingsHealth,
      },
      query: "Explain my credit health score of ${score.score}",
    );
  }

  String _buildPrompt(CreditHealthScore score) {
    return """
    Credit Score: ${score.score} (${score.category.name})
    Factors:
    - Payment Punctuality: ${score.paymentPunctuality.toStringAsFixed(1)}%
    - Credit Utilization: ${score.creditUtilization.toStringAsFixed(1)}%
    - Savings Health: ${score.savingsHealth.toStringAsFixed(1)}%
    - Spending Stability: ${score.spendingStability.toStringAsFixed(1)}%
    
    Explain why the score is this way and provide 2-3 specific tips to improve.
    Keep it encouraging but realistic.
    """;
  }
}
