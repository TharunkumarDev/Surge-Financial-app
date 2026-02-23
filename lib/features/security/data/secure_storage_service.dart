import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  // Add other keys as needed

  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(key: _keyAppLockEnabled, value: enabled.toString());
  }

  Future<bool> isAppLockEnabled() async {
    final value = await _storage.read(key: _keyAppLockEnabled);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
