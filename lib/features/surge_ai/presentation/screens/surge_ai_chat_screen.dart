import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/chat_message.dart';
import '../../domain/finance_intent.dart';
import '../../providers/surge_ai_providers.dart';
import '../../providers/bill_search_providers.dart';
import '../../../subscription/providers/subscription_providers.dart';
import '../../../subscription/domain/subscription_plan.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/quick_suggestion_chip.dart';
import '../widgets/animated_message_wrapper.dart';

class SurgeAIChatScreen extends ConsumerStatefulWidget {
  const SurgeAIChatScreen({super.key});
  
  @override
  ConsumerState<SurgeAIChatScreen> createState() => _SurgeAIChatScreenState();
}

class _SurgeAIChatScreenState extends ConsumerState<SurgeAIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Clear input
    _textController.clear();
    
    // Set loading state
    ref.read(aiLoadingStateProvider.notifier).state = true;
    
    try {
      final chatRepo = await ref.read(chatRepositoryProvider.future);
      
      // Save user message
      final userMessage = ChatMessage.user(text);
      await chatRepo.saveMessage(userMessage);
      
      // Scroll to bottom
      _scrollToBottom();
      
      // Check if this is a bill or expense search query
      final billSearchService = await ref.read(billSearchServiceFutureProvider.future);
      final billSearchResult = await billSearchService.searchBills(text);
      final expenseSearchResult = await billSearchService.searchExpenses(text);
      
      ChatMessage aiResponse;
      
      if (billSearchResult.hasResults) {
        // Bill search query - create response with bill attachments
        final responseText = billSearchService.generateResponseMessage(billSearchResult);
        final expenseIds = billSearchResult.expenses.map((e) => e.id).toList();
        
        aiResponse = ChatMessage.ai(
          responseText,
          expenseIds: expenseIds,
          hasBills: true,
        );
      } else if (expenseSearchResult.hasResults) {
        // Expense search query - create response with expense attachments
        final responseText = billSearchService.generateResponseMessage(expenseSearchResult, isExpenseSearch: true);
        final expenseIds = expenseSearchResult.expenses.map((e) => e.id).toList();
        
        aiResponse = ChatMessage.ai(
          responseText,
          expenseIds: expenseIds,
          hasBills: false,
        );
      } else if ((billSearchResult.searchQuery.isNotEmpty && text.toLowerCase().contains('bill')) ||
                 (expenseSearchResult.searchQuery.isNotEmpty && 
                  (text.toLowerCase().contains('expense') || text.toLowerCase().contains('spending')))) {
        // Search query but no results
        final responseText = text.toLowerCase().contains('bill')
            ? billSearchService.generateResponseMessage(billSearchResult)
            : billSearchService.generateResponseMessage(expenseSearchResult, isExpenseSearch: true);
        aiResponse = ChatMessage.ai(responseText);
      } else {
        // Regular AI query - use existing controller
        final controller = await ref.read(surgeAIControllerProvider.future);
        aiResponse = await controller.processQuery(text);
      }
      
      // Save AI message
      await chatRepo.saveMessage(aiResponse);
      
      // Increment daily chat count (if not Pro)
      final tier = ref.read(currentSubscriptionTierProvider);
      if (tier != SubscriptionTier.pro) {
        // TODO: Increment counter in subscription
      }
      
      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      // Clear loading state
      ref.read(aiLoadingStateProvider.notifier).state = false;
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _onSuggestionTap(QuickSuggestion suggestion) {
    _textController.text = suggestion.query;
  }
  
  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final suggestions = ref.watch(quickSuggestionsProvider);
    final isLoading = ref.watch(aiLoadingStateProvider);
    final isPro = ref.watch(currentSubscriptionTierProvider) == SubscriptionTier.pro;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.surfaceDark : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.surfaceDark : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppTheme.darkGreen),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.limeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/surge_logo.png',
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: isDarkMode ? AppTheme.limeAccent : AppTheme.darkGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Surge AI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : AppTheme.darkGreen,
                  ),
                ),
                Text(
                  'Finance Assistant • Online',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }
                
                // Use original order - AnimatedList with reverse:true will display correctly
                // (newest at bottom, oldest at top)
                
                return AnimatedList(
                  key: GlobalKey<AnimatedListState>(),
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  initialItemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index, animation) {
                    if (isLoading && index == 0) {
                      return FadeTransition(
                        opacity: animation,
                        child: const TypingIndicator(),
                      );
                    }
                    
                    final messageIndex = isLoading ? index - 1 : index;
                    final message = messages[messageIndex];
                    
                    return AnimatedMessageWrapper(
                      index: messageIndex,
                      isReversed: true,
                      child: MessageBubble(
                        message: message,
                        onRetry: message.status == MessageStatus.error
                            ? () => _sendMessage(message.content)
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading messages: $error'),
              ),
            ),
          ),

          // Quick Suggestions (Moved to bottom)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.surfaceDark.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: suggestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final suggestion = entry.value;
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: QuickSuggestionChip(
                        suggestion: suggestion,
                        isPro: isPro,
                        onTap: () => _onSuggestionTap(suggestion),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.limeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: isDarkMode ? AppTheme.limeAccent : AppTheme.darkGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'Welcome to Surge AI!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'I\'m your personal finance assistant. Ask me about your balance, spending, or get budget tips!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Try asking:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• "What\'s my current balance?"\n'
                    '• "How much did I spend this month?"\n'
                    '• "Show me my recent transactions"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputArea() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(aiLoadingStateProvider);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _textController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.grey[600],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: isLoading ? null : _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLoading ? null : () {
                HapticFeedback.mediumImpact();
                _sendMessage(_textController.text);
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isLoading 
                    ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!])
                    : AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isLoading)
                      BoxShadow(
                        color: AppTheme.limeAccent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: AppTheme.darkGreen,
                        size: 24,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
