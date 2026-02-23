/// Domain model for month-end balance forecast
class BalanceForecast {
  final double currentBalance;
  final double dailyAverageSpend;
  final int daysRemaining;
  final double projectedSpending;
  final double forecastBalance;
  final ForecastRisk riskLevel;
  final String explanation;
  final DateTime generatedAt;
  final String? recommendation;
  
  BalanceForecast({
    required this.currentBalance,
    required this.dailyAverageSpend,
    required this.daysRemaining,
    required this.projectedSpending,
    required this.forecastBalance,
    required this.riskLevel,
    required this.explanation,
    required this.generatedAt,
    this.recommendation,
  });
  
  bool get isLowBalance => forecastBalance < 1000;
  bool get isNegative => forecastBalance < 0;
  
  /// Calculate required daily spend to maintain target balance
  double calculateTargetDailySpend(double targetBalance) {
    if (daysRemaining <= 0) return 0;
    final availableToSpend = currentBalance - targetBalance;
    return availableToSpend / daysRemaining;
  }
  
  factory BalanceForecast.insufficient() {
    return BalanceForecast(
      currentBalance: 0,
      dailyAverageSpend: 0,
      daysRemaining: 0,
      projectedSpending: 0,
      forecastBalance: 0,
      riskLevel: ForecastRisk.unknown,
      explanation: 'Insufficient data to generate forecast. Add more expenses to see predictions.',
      generatedAt: DateTime.now(),
    );
  }
}

/// Risk level for balance forecast
enum ForecastRisk {
  safe,      // Balance > 5000
  moderate,  // Balance 1000-5000
  low,       // Balance 0-1000
  critical,  // Balance < 0
  unknown,   // Not enough data
}

extension ForecastRiskExtension on ForecastRisk {
  String get label {
    switch (this) {
      case ForecastRisk.safe:
        return 'Safe';
      case ForecastRisk.moderate:
        return 'Moderate';
      case ForecastRisk.low:
        return 'Low Balance';
      case ForecastRisk.critical:
        return 'Critical';
      case ForecastRisk.unknown:
        return 'Unknown';
    }
  }
  
  String get emoji {
    switch (this) {
      case ForecastRisk.safe:
        return '✅';
      case ForecastRisk.moderate:
        return '⚠️';
      case ForecastRisk.low:
        return '🔴';
      case ForecastRisk.critical:
        return '🚨';
      case ForecastRisk.unknown:
        return '❓';
    }
  }
}
