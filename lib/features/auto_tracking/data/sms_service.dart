import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_parser.dart';
import '../domain/auto_transaction.dart';

/// SMS Service - User-Initiated Sync Only (Play Store Compliant)
/// 
/// This service ONLY:
/// - Reads SMS inbox when user taps "Sync Now" (Android)
/// - Parses bank transaction alerts
/// - Returns parsed transactions for user review
class SmsService {
  final Telephony? _telephony = Platform.isAndroid ? Telephony.instance : null;
  final TransactionParser _parser = TransactionParser();

  /// Manually sync transactions from SMS inbox
  /// Called ONLY when user taps "Sync Transactions" button
  Future<List<AutoTransaction>> syncTransactionsFromInbox() async {
    if (!Platform.isAndroid || _telephony == null) {
      return []; // No-op on iOS/other platforms
    }

    final List<AutoTransaction> transactions = [];
    
    try {
      // Fetch recent SMS (last 30 days to avoid excessive processing)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final messages = await _telephony!.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThan(thirtyDaysAgo.millisecondsSinceEpoch.toString()),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
      
      for (var msg in messages) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          msg.date ?? DateTime.now().millisecondsSinceEpoch
        );
        
        final transaction = _parser.parseSms(
          msg.address ?? '', 
          msg.body ?? '', 
          date
        );
        
        if (transaction != null) {
          transactions.add(transaction);
        }
      }
    } catch (e) {
      // Permission denied or other error
      rethrow;
    }
    
    return transactions;
  }

  /// Check if SMS permission is granted
  Future<bool> hasSmsPermission() async {
    if (!Platform.isAndroid || _telephony == null) return false;
    return await _telephony!.requestSmsPermissions ?? false;
  }
}

final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});
