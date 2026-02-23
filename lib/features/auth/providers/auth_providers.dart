import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';
import '../../subscription/domain/subscription_plan.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Auth Repository provider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return AuthRepository(firebaseAuth, prefs);
});

// Auth state provider - listens to Firebase auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});

final selectedPlanProvider = StateProvider<SubscriptionTier>((ref) => SubscriptionTier.basic);

// Current auth user provider
final currentAuthUserProvider = FutureProvider<AuthUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repo = await ref.watch(authRepositoryProvider.future);
  
  return authState.when(
    data: (user) {
      if (user == null) return null;
      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        isFirstTime: false,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// First time user check provider
final isFirstTimeUserProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(authRepositoryProvider.future);
  return await repo.isFirstTimeUser();
});
