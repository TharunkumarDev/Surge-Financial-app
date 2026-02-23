import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_user.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _prefs;
  
  static const String _firstTimeKey = 'is_first_time_user';

  AuthRepository(this._firebaseAuth, this._prefs);

  // Sign in with email and password
  Future<AuthUser> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign in failed');
      }
      
      // Mark user as returning (not first time anymore)
      await markUserAsReturning();
      
      return AuthUser(
        uid: credential.user!.uid,
        email: credential.user!.email ?? email,
        isFirstTime: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthUser> signUpWithEmailPassword(String email, String password, {String? name}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      // Update Display Name if provided
      if (name != null && name.isNotEmpty) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload(); // Reload to ensure local user has updated details
      }
      
      // Mark user as returning after first signup
      await markUserAsReturning();
      
      return AuthUser(
        uid: credential.user!.uid,
        email: credential.user!.email ?? email,
        isFirstTime: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  // Check if first time user
  Future<bool> isFirstTimeUser() async {
    return _prefs.getBool(_firstTimeKey) ?? true;
  }

  // Mark user as returning
  Future<void> markUserAsReturning() async {
    await _prefs.setBool(_firstTimeKey, false);
  }

  // Reset first time flag (for testing)
  Future<void> resetFirstTimeFlag() async {
    await _prefs.remove(_firstTimeKey);
  }
}
