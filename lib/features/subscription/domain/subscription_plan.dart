enum SubscriptionTier {
  free,
  basic,
  pro;

  int get priceInRupees {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.basic:
        return 149;
      case SubscriptionTier.pro:
        return 199;
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  static SubscriptionTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'free':
        return SubscriptionTier.free;
      case 'basic':
        return SubscriptionTier.basic;
      case 'pro':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final int billCapturesThisMonth;
  final DateTime lastResetDate;
  final int dailyAIChatCount;
  final DateTime lastAIChatResetDate;

  SubscriptionPlan({
    required this.tier,
    required this.purchasedAt,
    this.expiresAt,
    required this.billCapturesThisMonth,
    required this.lastResetDate,
    this.dailyAIChatCount = 0,
    DateTime? lastAIChatResetDate,
  }) : lastAIChatResetDate = lastAIChatResetDate ?? DateTime.now();

  factory SubscriptionPlan.free() {
    return SubscriptionPlan(
      tier: SubscriptionTier.free,
      purchasedAt: DateTime.now(),
      expiresAt: null,
      billCapturesThisMonth: 0,
      lastResetDate: DateTime.now(),
      dailyAIChatCount: 0,
      lastAIChatResetDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tier': tier.name,
      'priceInRupees': tier.priceInRupees,
      'purchasedAt': purchasedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'billCapturesThisMonth': billCapturesThisMonth,
      'lastResetDate': lastResetDate.toIso8601String(),
      'dailyAIChatCount': dailyAIChatCount,
      'lastAIChatResetDate': lastAIChatResetDate.toIso8601String(),
    };
  }

  factory SubscriptionPlan.fromFirestore(Map<String, dynamic> data) {
    return SubscriptionPlan(
      tier: SubscriptionTier.fromString(data['tier'] ?? 'free'),
      purchasedAt: DateTime.parse(data['purchasedAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: data['expiresAt'] != null ? DateTime.parse(data['expiresAt']) : null,
      billCapturesThisMonth: data['billCapturesThisMonth'] ?? 0,
      lastResetDate: DateTime.parse(data['lastResetDate'] ?? DateTime.now().toIso8601String()),
      dailyAIChatCount: data['dailyAIChatCount'] ?? 0,
      lastAIChatResetDate: data['lastAIChatResetDate'] != null 
          ? DateTime.parse(data['lastAIChatResetDate']) 
          : DateTime.now(),
    );
  }

  SubscriptionPlan copyWith({
    SubscriptionTier? tier,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    int? billCapturesThisMonth,
    DateTime? lastResetDate,
    int? dailyAIChatCount,
    DateTime? lastAIChatResetDate,
  }) {
    return SubscriptionPlan(
      tier: tier ?? this.tier,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      billCapturesThisMonth: billCapturesThisMonth ?? this.billCapturesThisMonth,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      dailyAIChatCount: dailyAIChatCount ?? this.dailyAIChatCount,
      lastAIChatResetDate: lastAIChatResetDate ?? this.lastAIChatResetDate,
    );
  }
}
