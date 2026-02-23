
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/credit_health_score.dart';

abstract class CreditHealthRepository {
  /// Calculate the credit health score based on current data
  Future<CreditHealthScore> calculateCreditHealth();
  
  /// Get the history of credit scores
  Future<List<CreditHealthScore>> getScoreHistory();
}
