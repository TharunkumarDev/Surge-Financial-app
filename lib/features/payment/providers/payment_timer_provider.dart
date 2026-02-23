import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentTimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isExpired;

  PaymentTimerState({
    required this.remainingSeconds,
    this.isRunning = false,
    this.isExpired = false,
  });

  String get formattedTime {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  PaymentTimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isExpired,
  }) {
    return PaymentTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}

class PaymentTimerNotifier extends StateNotifier<PaymentTimerState> {
  Timer? _timer;
  static const int maxTime = 300; // 5 minutes
  static const String _storageKey = 'payment_session_expiry';

  PaymentTimerNotifier() : super(PaymentTimerState(remainingSeconds: maxTime));

  Future<void> startTimer() async {
    if (state.isRunning) return;

    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(seconds: maxTime));
    await prefs.setInt(_storageKey, expiryTime.millisecondsSinceEpoch);

    _startInternal(maxTime);
  }

  void _startInternal(int seconds) {
    state = state.copyWith(remainingSeconds: seconds, isRunning: true, isExpired: false);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        expire();
      }
    });
  }

  Future<void> restoreTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMillis = prefs.getInt(_storageKey);
    
    if (expiryMillis != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
      final remaining = expiryTime.difference(DateTime.now()).inSeconds;
      
      if (remaining > 0) {
        _startInternal(remaining);
      } else {
        expire();
      }
    }
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _clearStorage();
  }

  void expire() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: 0, isRunning: false, isExpired: true);
    _clearStorage();
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final paymentTimerProvider = StateNotifierProvider<PaymentTimerNotifier, PaymentTimerState>((ref) {
  return PaymentTimerNotifier();
});
