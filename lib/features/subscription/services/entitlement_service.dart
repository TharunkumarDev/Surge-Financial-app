import '../domain/subscription_plan.dart';
import '../domain/feature_entitlement.dart';

class EntitlementService {
  // Monthly bill capture limit for Basic plan
  static const int basicPlanMonthlyLimit = 10;

  // Check if user has access to a specific feature
  bool hasAccess(AppFeature feature, SubscriptionTier tier) {
    switch (feature) {
      // Free plan can only VIEW
      case AppFeature.viewWallet:
      case AppFeature.viewSpending:
      case AppFeature.addExpense:
      case AppFeature.editExpense:
      case AppFeature.deleteExpense:
         return true; // All plans can view and manage expenses
      
      // Basic and Pro can add/edit
      case AppFeature.addWallet:
        return tier == SubscriptionTier.basic || tier == SubscriptionTier.pro;
      
      // Basic and Pro can capture bills (with limits for Basic)
      case AppFeature.captureBill:
      case AppFeature.scanner:
        return tier == SubscriptionTier.basic || tier == SubscriptionTier.pro;
      
      // Basic and Pro can view analytics
      case AppFeature.viewAnalytics:
        return tier == SubscriptionTier.basic || tier == SubscriptionTier.pro;
      
      // Only Pro can access AI insights and Advanced Reporting
      case AppFeature.aiInsights:
      case AppFeature.advancedReporting:
        return tier == SubscriptionTier.pro;
      
      // All plans can export data
      case AppFeature.exportData:
        return true;
      
      // Basic and Pro can sync transactions
      case AppFeature.transactionSync:
        return tier == SubscriptionTier.basic || tier == SubscriptionTier.pro;
      
      // Surge AI features
      case AppFeature.surgeAIBasic:
        return true; // All plans can use basic AI
      
      case AppFeature.surgeAIUnlimited:
      case AppFeature.surgeAIInsights:
      case AppFeature.surgeAIBudgetPlanning:
        return tier == SubscriptionTier.pro; // Pro only
    }
  }

  // Check if user can add expense
  bool canAddExpense(SubscriptionTier tier) {
    return hasAccess(AppFeature.addExpense, tier);
  }

  // Check if user can add wallet amount
  bool canAddWallet(SubscriptionTier tier) {
    return hasAccess(AppFeature.addWallet, tier);
  }

  // Check if user can capture bill (considering monthly limit for Basic)
  bool canCaptureBill(SubscriptionTier tier, int currentMonthCaptures) {
    if (!hasAccess(AppFeature.captureBill, tier)) {
      return false;
    }
    
    // Pro has unlimited captures
    if (tier == SubscriptionTier.pro) {
      return true;
    }
    
    // Basic has monthly limit
    if (tier == SubscriptionTier.basic) {
      return currentMonthCaptures < basicPlanMonthlyLimit;
    }
    
    return false;
  }

  // Get remaining bill captures for current month
  int getRemainingCaptures(SubscriptionTier tier, int currentMonthCaptures) {
    if (tier == SubscriptionTier.pro) {
      return -1; // Unlimited
    }
    
    if (tier == SubscriptionTier.basic) {
      final remaining = basicPlanMonthlyLimit - currentMonthCaptures;
      return remaining > 0 ? remaining : 0;
    }
    
    return 0; // Free plan
  }

  // Receipt Archive & Multi-Image Entitlements
  
  /// Check if user can access receipt archive (Pro only)
  bool canAccessReceiptArchive(SubscriptionTier tier) {
    return tier == SubscriptionTier.pro;
  }

  /// Check if user can search receipts (Pro only)
  bool canSearchReceipts(SubscriptionTier tier) {
    return tier == SubscriptionTier.pro;
  }

  /// Get maximum bill images allowed per expense
  /// Free: 0, Basic: 1, Pro: unlimited (-1)
  int getMaxBillImagesPerExpense(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.basic:
        return 1;
      case SubscriptionTier.pro:
        return -1; // Unlimited
    }
  }

  /// Check if user can attach more images to an expense
  bool canAttachMoreImages(SubscriptionTier tier, int currentImageCount) {
    final maxImages = getMaxBillImagesPerExpense(tier);
    if (maxImages == -1) return true; // Unlimited
    return currentImageCount < maxImages;
  }

  /// Check if user can export PDFs
  /// Free: false (must upgrade), Basic: true, Pro: true
  bool canExportPdf(SubscriptionTier tier) {
    return tier == SubscriptionTier.basic || tier == SubscriptionTier.pro;
  }

  // Get feature description for upgrade prompt
  String getFeatureDescription(AppFeature feature) {
    switch (feature) {
      case AppFeature.viewWallet:
        return 'View wallet balance';
      case AppFeature.viewSpending:
        return 'View total spending';
      case AppFeature.addWallet:
        return 'Add wallet amount';
      case AppFeature.addExpense:
        return 'Add expenses';
      case AppFeature.editExpense:
        return 'Edit expenses';
      case AppFeature.deleteExpense:
        return 'Delete expenses';
      case AppFeature.captureBill:
        return 'Capture bills with camera';
      case AppFeature.viewAnalytics:
        return 'View analytics and reports';
      case AppFeature.aiInsights:
        return 'AI spending insights';
      case AppFeature.scanner:
        return 'Bill scanner';
      case AppFeature.exportData:
        return 'Export data';
      case AppFeature.advancedReporting:
        return 'Advanced cashflow reports';
      case AppFeature.transactionSync:
        return 'Transaction Sync from SMS';
      case AppFeature.surgeAIBasic:
        return 'Basic AI financial assistant';
      case AppFeature.surgeAIUnlimited:
        return 'Unlimited AI conversations';
      case AppFeature.surgeAIInsights:
        return 'AI-powered financial insights';
      case AppFeature.surgeAIBudgetPlanning:
        return 'AI budget planning and forecasting';
    }
  }

  // Get minimum required tier for feature
  SubscriptionTier getMinimumTierForFeature(AppFeature feature) {
    switch (feature) {
      case AppFeature.viewWallet:
      case AppFeature.viewSpending:
      case AppFeature.exportData:
      case AppFeature.addExpense:
      case AppFeature.editExpense:
      case AppFeature.deleteExpense:
      case AppFeature.surgeAIBasic:
        return SubscriptionTier.free;
      
      case AppFeature.addWallet:
      case AppFeature.captureBill:
      case AppFeature.scanner:
      case AppFeature.viewAnalytics:
      case AppFeature.transactionSync:
        return SubscriptionTier.basic;
      
      case AppFeature.aiInsights:
      case AppFeature.advancedReporting:
      case AppFeature.surgeAIUnlimited:
      case AppFeature.surgeAIInsights:
      case AppFeature.surgeAIBudgetPlanning:
        return SubscriptionTier.pro;
    }
  }
}
