import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/biometric_auth_service.dart';
import '../data/secure_storage_service.dart';

// --- State ---

class SecurityState {
  final bool isAppLockEnabled;
  final bool isBiometricEnabled;
  final bool isLocked;
  final bool isAuthenticated;

  SecurityState({
    this.isAppLockEnabled = false,
    this.isBiometricEnabled = false,
    this.isLocked = true, // Fail Closed: Start locked by default
    this.isAuthenticated = false,
  });

  SecurityState copyWith({
    bool? isAppLockEnabled,
    bool? isBiometricEnabled,
    bool? isLocked,
    bool? isAuthenticated,
  }) {
    return SecurityState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isLocked: isLocked ?? this.isLocked,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// --- Controller ---

class AppLockController extends StateNotifier<SecurityState> {
  final SecureStorageService _storage;
  final BiometricAuthService _authService;
  
  DateTime? _pausedTime;
  // TODO: Make this configurable in settings
  static const Duration _lockTimeout = Duration(seconds: 0); // Immediate lock by default for higher security

  AppLockController(this._storage, this._authService) : super(SecurityState()) {
    _init();
  }

  Future<void> _init() async {
    final lockEnabled = await _storage.isAppLockEnabled();
    final bioEnabled = await _storage.isBiometricEnabled();
    
    if (!lockEnabled) {
      // If lock is disabled, unlock immediately
      state = state.copyWith(
        isAppLockEnabled: false,
        isBiometricEnabled: bioEnabled,
        isLocked: false,
        isAuthenticated: true,
      );
    } else {
      // If locked, keep isLocked=true (default) and verify auth
      state = state.copyWith(
        isAppLockEnabled: true,
        isBiometricEnabled: bioEnabled,
      );
      // Optional: Auto-trigger auth on startup? 
      // Often better to let the UI (AppLockScreen) trigger it to avoid race conditions with context.
    }
  }

  Future<void> enableAppLock(bool enable) async {
    await _storage.setAppLockEnabled(enable);
    state = state.copyWith(isAppLockEnabled: enable);
    if (!enable) {
      state = state.copyWith(isLocked: false, isAuthenticated: true);
    } else {
      // If just enabled, we consider them authenticated for this session
      state = state.copyWith(isAuthenticated: true); 
    }
  }

  Future<void> enableBiometric(bool enable) async {
    await _storage.setBiometricEnabled(enable);
    state = state.copyWith(isBiometricEnabled: enable);
  }

  void lockApp() {
    if (state.isAppLockEnabled) {
      state = state.copyWith(isLocked: true, isAuthenticated: false);
    }
  }

  Future<bool> unlockApp() async {
    if (!state.isAppLockEnabled) {
      state = state.copyWith(isLocked: false, isAuthenticated: true);
      return true;
    }

    // Attempt Authentication
    // We always allow device credentials fallback (PIN/Pattern) for banking-grade reliability
    try {
      final authenticated = await _authService.authenticate(
        localizedReason: 'Authenticate to access Surge',
        stickyAuth: true,
      );

      if (authenticated) {
        state = state.copyWith(isLocked: false, isAuthenticated: true);
        return true;
      }
    } catch (e) {
      debugPrint("Auth failed: $e");
    }
    
    return false;
  }

  void onAppPaused() {
    if (state.isAppLockEnabled) {
      _pausedTime = DateTime.now();
    }
  }

  void onAppResumed() {
    if (state.isAppLockEnabled && _pausedTime != null) {
      final diff = DateTime.now().difference(_pausedTime!);
      // If timeout exceeded or if we enforce immediate lock (duration 0)
      if (diff >= _lockTimeout) {
        lockApp();
      }
      _pausedTime = null; 
    }
  }
}

// --- Providers ---

final securityStateProvider = StateNotifierProvider<AppLockController, SecurityState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final authService = ref.watch(biometricAuthServiceProvider);
  return AppLockController(storage, authService);
});
