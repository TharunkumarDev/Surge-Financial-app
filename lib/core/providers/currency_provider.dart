import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<Currency> kCurrencies = [
  Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  Currency(code: 'EUR', symbol: '€', name: 'Euro'),
  Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  Currency(code: 'AED', symbol: 'AED', name: 'United Arab Emirates Dirham'),
];

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(kCurrencies[0]) {
    _loadCurrency();
  }

  static const _key = 'selected_currency_code';

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_key);
    if (savedCode != null) {
      state = kCurrencies.firstWhere(
        (c) => c.code == savedCode,
        orElse: () => kCurrencies[0],
      );
    }
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency.code);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});
