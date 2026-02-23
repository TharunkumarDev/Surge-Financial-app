import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_pro/features/wallet/data/wallet_repository.dart';
import 'package:expense_tracker_pro/features/expense/data/expense_repository.dart';
import 'package:expense_tracker_pro/features/subscription/data/subscription_repository.dart';
import 'package:expense_tracker_pro/features/subscription/domain/subscription_reminder.dart';
import '../../domain/repositories/credit_health_repository.dart';
import '../../domain/entities/credit_health_score.dart';
import '../datasources/credit_scoring_engine.dart';
import '../../domain/services/ai_credit_explainer.dart';
import '../../../auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditHealthRepositoryImpl implements CreditHealthRepository {
  final ExpenseRepository _expenseRepo;
  final SubscriptionRepository _subRepo;
  final WalletRepository _walletRepo;
  final CreditScoringEngine _engine;
  final AICreditExplainer _aiExplainer;
  final FirebaseFirestore _firestore;
  final String _userId;

  CreditHealthRepositoryImpl({
    required ExpenseRepository expenseRepo,
    required SubscriptionRepository subRepo,
    required WalletRepository walletRepo,
    required CreditScoringEngine engine,
    required AICreditExplainer aiExplainer,
    required FirebaseFirestore firestore,
    required String userId,
  }) : _expenseRepo = expenseRepo,
       _subRepo = subRepo,
       _walletRepo = walletRepo,
       _engine = engine,
       _aiExplainer = aiExplainer,
       _firestore = firestore,
       _userId = userId;

  @override
  Future<CreditHealthScore> calculateCreditHealth() async {
    // 1. Fetch Data
    final expenses = await _expenseRepo.getAllExpenses();
    final wallet = await _walletRepo.getWallet();

    // 2. Calculate Score
    final creationDate = DateTime.now().subtract(const Duration(days: 365)); 

    final appSub = await _subRepo.getUserSubscription(_userId);
    final appSubReminder = SubscriptionReminder(
        id: 'app_sub',
        tier: appSub.tier,
        planStartDate: appSub.purchasedAt,
        planExpiryDate: appSub.expiresAt ?? DateTime.now().add(const Duration(days: 30)),
        scheduledReminders: [],
    );

    final score = _engine.calculateScore(
      expenses: expenses,
      subscriptions: [appSubReminder], 
      monthlyIncome: wallet?.initialBalance ?? 0.0,
      accountCreationDate: creationDate,
    );
    
    // 3. Get AI Explanation
    final explanation = await _aiExplainer.generateExplanation(score);
    
    // 4. Enrich Score
    final enrichedScore = CreditHealthScore(
      score: score.score,
      category: score.category,
      calculatedAt: score.calculatedAt,
      paymentPunctuality: score.paymentPunctuality,
      creditUtilization: score.creditUtilization,
      savingsHealth: score.savingsHealth,
      spendingStability: score.spendingStability,
      creditMix: score.creditMix,
      aiExplanation: explanation,
      improvementTips: score.improvementTips,
    );

    // 5. Persist to Firestore (Current + History)
    if (_userId.isNotEmpty) {
      final batch = _firestore.batch();
      
      // Save current score
      final currentRef = _firestore.collection('users').doc(_userId).collection('credit_health').doc('current');
      batch.set(currentRef, enrichedScore.toFirestore());
      
      // Save history entry (Key: YYYY-MM)
      final now = DateTime.now();
      final historyKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      final historyRef = _firestore.collection('users').doc(_userId).collection('credit_health_history').doc(historyKey);
      batch.set(historyRef, enrichedScore.toFirestore());

      await batch.commit();
    }
    
    return enrichedScore;
  }

  @override
  Future<List<CreditHealthScore>> getScoreHistory() async {
    if (_userId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('credit_health_history')
          .orderBy('calculatedAt', descending: true)
          .limit(12) // Last 12 months
          .get();

      return snapshot.docs.map((doc) => CreditHealthScore.fromFirestore(doc.data())).toList();
    } catch (e) {
      // Return empty list on error or offline
      return [];
    }
  }
}
