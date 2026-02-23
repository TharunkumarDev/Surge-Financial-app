import 'package:flutter/foundation.dart';

class ParsedBillData {
  final double amount;
  final String currency;
  final DateTime? date;
  final String? merchantName;
  final int confidence;
  final String sourceKeyword;

  ParsedBillData({
    required this.amount,
    this.currency = 'INR',
    this.date,
    this.merchantName,
    this.confidence = 0,
    this.sourceKeyword = '',
  });

  @override
  String toString() {
    return 'ParsedBillData(amount: $amount, currency: $currency, confidence: $confidence, source: $sourceKeyword)';
  }
}

class AdvancedHeuristicParser {
  // Regex for Currency Amounts: Matches ₹, Rs, INR, or bare numbers like 1,234.56
  // Group 1: Currency Symbol (optional)
  // Group 2: Amount
  static final _amountRegex = RegExp(r'(?:\$|₹|Rs\.?|INR)?\s?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);

  // Keywords ordered by strict priority
  static const _tier1Keywords = ['round off', 'rounded', 'final amount', 'payable', 'net payable'];
  static const _tier2Keywords = ['grand total', 'total amount', 'total'];
  static const _tier3Keywords = ['net amount', 'due', 'amount due'];
  // Subtotal is explicitly lower priority/ignored if others exist, but kept for fallback
  static const _tier4Keywords = ['subtotal', 'sub total'];

  // Rejection Keywords (Critical)
  static final _rejectionKeywords = [
    'bill no', 'invoice no', 'order no', 'table no', 'gstin', 'ph:', 'phone', 'qty', 'item', 'serial', 's.no'
  ];

  ParsedBillData parseReceiptText(String text) {
    if (text.isEmpty) {
      return ParsedBillData(amount: 0.0);
    }

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    // 1. Extract Merchant (Heuristic: First valid line usually)
    String? merchant;
    for (var line in lines) {
      if (line.length > 3 && !_hasRejectionKeyword(line)) {
        merchant = line;
        break;
      }
    }

    // 2. Extract Date
    final date = _parseDate(text);

    // 3. Extract Amount with Strict Priority
    final amountData = _extractAmountStrict(lines);

    return ParsedBillData(
      amount: amountData.amount,
      currency: amountData.currency,
      date: date ?? DateTime.now(),
      merchantName: merchant,
      confidence: amountData.confidence,
      sourceKeyword: amountData.sourceKeyword,
    );
  }

  bool _hasRejectionKeyword(String line) {
    final lowerLine = line.toLowerCase();
    return _rejectionKeywords.any((k) => lowerLine.contains(k));
  }

  // Returns ParsedBillData with only amount/confidence filled
  ParsedBillData _extractAmountStrict(List<String> lines) {
    List<_CandidateAmount> candidates = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lowerLine = line.toLowerCase();

      // Skip lines with rejection keywords
      if (_hasRejectionKeyword(line)) continue;

      // Indian Context: Ignore strictly Tax lines if they are not the total
      if (lowerLine.startsWith('cgst') || lowerLine.startsWith('sgst') || lowerLine.startsWith('igst') || lowerLine.startsWith('vat')) {
        continue; 
      }

      // Find all matches in line
      final matches = _amountRegex.allMatches(line);
      for (final match in matches) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        if (amountStr == null) continue;
        
        final val = double.tryParse(amountStr);
        if (val == null || val == 0) continue;
        
        // Context check: Look at this line and previous line for keywords
        String contextText = lowerLine;
        if (i > 0) contextText += " ${lines[i-1].toLowerCase()}";

        // Determine Tier
        int tier = 99; // Default low priority
        String keyword = '';

        if (_containsAny(contextText, _tier1Keywords)) { tier = 1; keyword = 'Tier 1'; }
        else if (_containsAny(contextText, _tier2Keywords)) { tier = 2; keyword = 'Tier 2'; }
        else if (_containsAny(contextText, _tier3Keywords)) { tier = 3; keyword = 'Tier 3'; }
        else if (_containsAny(contextText, _tier4Keywords)) { tier = 4; keyword = 'Tier 4'; }

        // Sanity Check: If integer > 1000 and NO currency symbol, likely an ID/Phone
        final hasCurrencySymbol = line.contains('₹') || lowerLine.contains('rs') || lowerLine.contains('inr');
        if (val > 1000 && val % 1 == 0 && !hasCurrencySymbol && tier == 99) {
          continue; 
        }

        // Calculate Confidence
        int confidence = 50;
        if (hasCurrencySymbol) confidence += 20;
        if (tier < 4) confidence += 20;
        // Boost if near bottom (last 20% of lines)
        if (i > lines.length * 0.8) confidence += 10;
        if (tier == 99) confidence -= 30; // Random number guess

        candidates.add(_CandidateAmount(val, tier, i, confidence, keyword));
      }
    }

    if (candidates.isEmpty) return ParsedBillData(amount: 0.0);

    // Sort: 
    // 1. Tier (Ascending, 1 is best)
    // 2. Value (Descending - prefer higher totals? Actually usually the Payable is higher or same. 
    //    But careful of "Cash Tendered" > "Bill Amount". 
    //    Let's stick to Tier. If Tie, prefer position (bottom-most).
    candidates.sort((a, b) {
      if (a.tier != b.tier) return a.tier.compareTo(b.tier);
      return b.lineIndex.compareTo(a.lineIndex); // Bottom-most first
    });

    final best = candidates.first;
    
    // Final check for "Round Off" logic
    // If we found a "Round Off" line, usually the number ON that line is small (0.xx). 
    // The Final Total is often on the NEXT line or the same line.
    // If our best candidate is < 1.0 and keyword is "Round Off", we might have picked the adjustment value.
    if (best.value < 10 && (best.sourceKeyword.contains('Tier 1'))) {
       // Try to find a larger value nearby?
       // Actually, priority rules might handle this if we define "Final Amount" keyword properly.
       // But if the receipt says:
       // Total: 100.40
       // Round off: -0.40
       // Payable: 100.00
       // Our Tier 1 looks for "Payable" or "Round Off". 
       // If "Round Off" line has "-0.40", we don't want that. 
       // We strictly want the Payable amount.
       // Let's refine strict keywords: "Round Off" itself is ambiguous (could be the label for the adjustment).
       // "Rounded" or "Rounded Total" is better.
       // Let's rely on the candidates sorting.
    }

    return ParsedBillData(
      amount: best.value,
      confidence: best.confidence,
      sourceKeyword: best.sourceKeyword.isEmpty ? 'Heuristic' : best.sourceKeyword,
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  DateTime? _parseDate(String text) {
    // Regex for DD/MM/YYYY, YYYY-MM-DD, DD-MMM-YYYY
    // Prioritize DD/MM/YYYY for India
    final datePatterns = [
       RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})'), // 12/31/2023 or 31-12-23
      RegExp(r'(\d{4})[./-](\d{1,2})[./-](\d{1,2})'),  // 2023-12-31
      RegExp(r'(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[a-z]*\s+(\d{2,4})', caseSensitive: false),
    ];

    for (var pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
           if (match.groupCount == 3) {
            final g1 = match.group(1)!;
            final g2 = match.group(2)!;
            final g3 = match.group(3)!;

            if (pattern.pattern.contains('JAN')) {
              // Handle Month names
              final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
              final month = months.indexOf(g2.toLowerCase().substring(0, 3)) + 1;
              final day = int.parse(g1);
              var year = int.parse(g3);
              if (year < 100) year += 2000;
              return DateTime(year, month, day);
            } else if (g1.length == 4) {
              // YYYY-MM-DD
               return DateTime(int.parse(g1), int.parse(g2), int.parse(g3));
            } else {
              // Europe/India: DD/MM/YYYY
              final d1 = int.parse(g1);
              final d2 = int.parse(g2);
              var year = int.parse(g3);
              if (year < 100) year += 2000;
              
              if (d1 > 12) {
                 return DateTime(year, d2, d1); // Clearly DD/MM
              } else {
                 // Assume DD/MM for Indian context preference
                 return DateTime(year, d2, d1); 
              }
            }
           }
        } catch (e) {
          // ignore
        }
      }
    }
    return null;
  }
}

class _CandidateAmount {
  final double value;
  final int tier;
  final int lineIndex;
  final int confidence;
  final String sourceKeyword;

  _CandidateAmount(this.value, this.tier, this.lineIndex, this.confidence, this.sourceKeyword);
}
