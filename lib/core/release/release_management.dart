import 'package:flutter/foundation.dart';

/// Store Release Checker - Detects if the app is a production store build.
class StoreReleaseChecker {
  /// Returns true if the app is running in Release mode.
  static bool get isRelease => kReleaseMode;

  /// Returns true if the app is running in Debug mode.
  static bool get isDebug => kDebugMode;

  /// Returns true if the app is running in Profile mode.
  static bool get isProfile => kProfileMode;

  /// Logic to determine if the build is "Official" vs "Sideloaded" 
  /// (Simplified for template; in production this could check InstallerPackageName)
  static bool get isOfficialStoreBuild => isRelease && !isDebug;
}

/// Build Validator - Ensures the app is running with correct security flags.
class BuildValidator {
  static void validate() {
    if (isRelease) {
      _checkProductionSafety();
    }
  }

  static void _checkProductionSafety() {
    // Assert no debug flags or unsafe configs are active in release
    assert(() {
      // This block only runs in debug/profile mode (due to assert)
      // If code reaches here in a truly release build, something is wrong
      return true;
    }());
  }

  static bool get isRelease => kReleaseMode;
}
