import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_pro/features/scanner/data/services/advanced_heuristic_parser.dart';

void main() {
  late AdvancedHeuristicParser parser;

  setUp(() {
    parser = AdvancedHeuristicParser();
  });

  group('AdvancedHeuristicParser Tests', () {
    test('Happy Path: Extracts "Grand Total" correctly', () {
      final text = '''
      Store Name
      Item 1   100.00
      Item 2   200.00
      Grand Total: ₹300.00
      Thank you
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 300.0);
      expect(result.currency, 'INR');
    });

    test('Priority: "Round Off" > "Total"', () {
      final text = '''
      Subtotal: 99.40
      Total: 99.40
      Round Off: 0.60
      Final Amount: 100.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 100.0);
      expect(result.sourceKeyword, contains('Tier 1'));
    });

    test('Rejection: Ignores Bill No and Phone', () {
      final text = '''
      Bill No: 123456
      Ph: 9876543210
      Item A   50.00
      Total: 50.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 50.0);
    });

    test('Indian Context: Ignores Tax Lines (CGST/SGST)', () {
      final text = '''
      Item A   100.00
      CGST 9%: 9.00
      SGST 9%: 9.00
      Total: 118.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 118.0);
    });

    test('Date Parsing: Indian Format DD/MM/YYYY', () {
      final text = '''
      Date: 31/12/2023
      Total: 500.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.date?.year, 2023);
      expect(result.date?.month, 12);
      expect(result.date?.day, 31);
    });
    
    test('Date Parsing: 31 Jan 2023', () {
      final text = '''
      Date: 31 Jan 2023
      Total: 500.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.date?.year, 2023);
      expect(result.date?.month, 1);
      expect(result.date?.day, 31);
    });

    test('Rejection: Large Integer without context', () {
      final text = '''
      Order ID 999999
      12345
      Total: 500.00
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 500.0);
    });
    
    test('No Keywords: Pick largest valid amount near bottom', () {
       // Assuming fallback logic for no keywords (though currently confidence might be low, it should pick value)
       // The parser logic says if no candidates, return 0. 
       // If candidates exist but no tier (Tier 99), it picks based on position/confidence.
      final text = '''
      Item 1 50
      Item 2 100
      150
      ''';
      final result = parser.parseReceiptText(text);
      expect(result.amount, 150.0);
    });
  });
}
