import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService() : _auth = LocalAuthentication();

  /// Checks if the device supports biometric authentication or valid device credentials.
  Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Checks if biometrics can actually be used (enrolled and available).
  Future<bool> get canCheckBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Returns the list of available biometrics (Face, Fingerprint, Iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  /// Authenticates the user using biometrics or device PIN/pattern.
  /// 
  /// [localizedReason] is shown to the user in the dialog.
  /// Returns [true] if authenticated successfully, [false] otherwise.
  Future<bool> authenticate({
    required String localizedReason,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    try {
      final canAuth = await isDeviceSupported;
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow device PIN fallback
          sensitiveTransaction: sensitiveTransaction,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
  
  /// Cancels any active authentication.
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});
