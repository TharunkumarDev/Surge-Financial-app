import 'package:flutter/foundation.dart';
import 'auto_transaction.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class TransactionParser {
  // Common keywords to identify bank SMS
  static const List<String> _bankKeywords = [
    'debited', 'spent', 'txn', 'transaction', 'sent', 'paid', 'purchased', 'ac', 'credit card', 'debit card', 'bank'
  ];

  static const List<String> _ignoreKeywords = [
    'otp', 'verification', 'code', 'login', 'auth', 'fund transfer', 'request'
  ];

  // Regex Patterns
  // Matches amounts like "Rs. 100.00", "INR 500", "Rs 1,200", "worth Rs. 50"
  static final RegExp _amountRegex = RegExp(r'(?:Rs\.?|INR|worth|amounted to)\s*[\d,]+(?:\.\d{2})?', caseSensitive: false);
  
  // Merchant regex: "at [MERCHANT]", "to [MERCHANT]", "info [MERCHANT]", "vpa [MERCHANT]"
  static final RegExp _merchantRegex = RegExp(r'(?:at|to|info|vpa|into)\s+([A-Za-z0-9\s\#\.\*\/]+?)(?:\.|on|ref|txn|via|from|date|using|at)', caseSensitive: false);

  /// Main method to parse an incoming SMS
  AutoTransaction? parseSms(String sender, String body, DateTime receivedAt) {
    if (!_isValidBankSms(sender, body)) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null; 

    final type = _determineType(body);
    // Ignore credit transactions for now if required (keeping it for flexible UI)
    
    final merchant = _extractMerchant(body);
    
    final hash = _generateHash(sender, amount, receivedAt, body);

    return AutoTransaction(
      hash: hash,
      originalSmsBody: body,
      senderId: sender,
      receivedAt: receivedAt,
      amount: amount,
      merchantName: merchant,
      type: type,
    );
  }

  bool _isValidBankSms(String sender, String body) {
    if (sender.length < 3) return false;
    
    final lowerBody = body.toLowerCase();
    
    // Ignore OTP and login alerts
    for (var keyword in _ignoreKeywords) {
      if (lowerBody.contains(keyword)) return false;
    }

    // Check for bank keywords
    for (var keyword in _bankKeywords) {
      if (lowerBody.contains(keyword)) return true;
    }
    
    // Special check for UPI/VPA patterns which are common for bank transactions
    if (lowerBody.contains('upi') || lowerBody.contains('vpa')) return true;

    return false;
  }

  double? _extractAmount(String body) {
    final match = _amountRegex.firstMatch(body);
    if (match != null) {
      String rawAmount = match.group(0)!;
      // Clean up string: remove Rs, INR, worth, commas, spaces
      rawAmount = rawAmount.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(rawAmount);
    }
    return null;
  }

  String _extractMerchant(String body) {
    final match = _merchantRegex.firstMatch(body);
    if (match != null && match.groupCount >= 1) {
      final merchant = match.group(1)!.trim();
      if (merchant.length > 2) return merchant;
    }
    return 'Unknown Merchant';
  }

  TransactionType _determineType(String body) {
    final lowerBody = body.toLowerCase();
    if (lowerBody.contains('debited') || lowerBody.contains('spent') || lowerBody.contains('paid') || lowerBody.contains('sent') || lowerBody.contains('withdraw')) {
      return TransactionType.debit;
    } else if (lowerBody.contains('credited') || lowerBody.contains('received') || lowerBody.contains('refund') || lowerBody.contains('reversed')) {
      return TransactionType.credit;
    }
    return TransactionType.unknown;
  }

  String _generateHash(String sender, double amount, DateTime date, String body) {
    // Create a deterministic hash for duplicate detection
    // Using body length helps uniqueness along with time and amount
    final rawString = '$sender-${amount.toStringAsFixed(2)}-${date.year}${date.month}${date.day}-${body.length}';
    var bytes = utf8.encode(rawString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
