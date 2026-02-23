
import 'package:flutter/foundation.dart';

enum CreditHealthCategory {
  poor,      // 0-500
  fair,      // 500-650
  good,      // 650-750
  veryGood,  // 750-800
  excellent  // 800-900
}

class CreditHealthScore {
  final int score;
  final CreditHealthCategory category;
  final DateTime calculatedAt;
  
  // Deterministic Factors (Normalized 0-100)
  final double paymentPunctuality;
  final double creditUtilization;
  final double savingsHealth;
  final double spendingStability;
  final double creditMix;
  
  // AI Generated Insights
  final String? aiExplanation;
  final List<String> improvementTips;
  
  const CreditHealthScore({
    required this.score,
    required this.category,
    required this.calculatedAt,
    required this.paymentPunctuality,
    required this.creditUtilization,
    required this.savingsHealth,
    required this.spendingStability,
    required this.creditMix,
    this.aiExplanation,
    this.improvementTips = const [],
  });

  Map<String, dynamic> toFirestore() {
    return {
      'score': score,
      'category': category.name,
      'calculatedAt': calculatedAt.toIso8601String(),
      'paymentPunctuality': paymentPunctuality,
      'creditUtilization': creditUtilization,
      'savingsHealth': savingsHealth,
      'spendingStability': spendingStability,
      'creditMix': creditMix,
      'aiExplanation': aiExplanation,
      'improvementTips': improvementTips,
    };
  }

  factory CreditHealthScore.fromFirestore(Map<String, dynamic> data) {
    return CreditHealthScore(
      score: data['score'] as int,
      category: CreditHealthCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => CreditHealthCategory.poor,
      ),
      calculatedAt: DateTime.parse(data['calculatedAt']),
      paymentPunctuality: (data['paymentPunctuality'] as num).toDouble(),
      creditUtilization: (data['creditUtilization'] as num).toDouble(),
      savingsHealth: (data['savingsHealth'] as num).toDouble(),
      spendingStability: (data['spendingStability'] as num).toDouble(),
      creditMix: (data['creditMix'] as num).toDouble(),
      aiExplanation: data['aiExplanation'] as String?,
      improvementTips: (data['improvementTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  factory CreditHealthScore.initial() {
    return CreditHealthScore(
      score: 0,
      category: CreditHealthCategory.poor,
      calculatedAt: DateTime.now(),
      paymentPunctuality: 0,
      creditUtilization: 0,
      savingsHealth: 0,
      spendingStability: 0,
      creditMix: 0,
      aiExplanation: "Not enough data to calculate score.",
      improvementTips: [],
    );
  }
}
