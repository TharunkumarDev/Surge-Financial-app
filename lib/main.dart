import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/security/providers/security_providers.dart';
import 'features/security/presentation/screens/app_lock_screen.dart';
import 'features/security/presentation/screens/security_settings_screen.dart';
import 'features/security/presentation/screens/security_setup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/design_system.dart';
import 'features/expense/presentation/add_expense_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/scanner/presentation/scanner_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/navigation/presentation/scaffold_with_nav_bar.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/subscription/presentation/pricing_screen.dart';
import 'features/payment/presentation/checkout_screen.dart';
import 'features/payment/presentation/payment_status_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auto_tracking/providers/auto_tracking_providers.dart';
import 'features/auto_tracking/presentation/sms_review_screen.dart';
import 'features/profile/providers/theme_provider.dart';
import 'features/subscription/data/reminder_notification_service.dart';
import 'features/surge_ai/presentation/screens/surge_ai_chat_screen.dart';
import 'features/credit_health/presentation/screens/credit_health_screen.dart';
import 'features/subscription/presentation/screens/subscriptions_screen.dart';
import 'features/loan/presentation/screens/loans_screen.dart';
import 'features/subscription/presentation/screens/add_subscription_screen.dart';
import 'features/loan/presentation/screens/add_loan_screen.dart';
import 'core/services/reminder_service.dart';
import 'core/release/release_management.dart';
import 'core/release/permission_compliance_scanner.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isFirstTimeAsync = ref.watch(isFirstTimeUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      final user = authState.value;
      final isFirstTime = isFirstTimeAsync.value ?? true;
      final path = state.uri.path;
      final isAuthScreen = path == '/login' || 
                           path == '/signup' || 
                           path == '/welcome';
      final isPaymentScreen = path == '/checkout' || 
                              path == '/payment-status' ||
                              path == '/pricing';

      // 1. Not logged in
      if (user == null) {
        // If not already on auth or payment screens, redirect
        if (!isAuthScreen && !isPaymentScreen) {
          if (isFirstTime) return '/welcome';
          return '/login';
        }
        return null; // Stay on current screen
      }

      // 2. Logged in - don't allow auth screens (except welcome if needed, usually not)
      if (isAuthScreen) {
        return '/home';
      }

      // Allow access to home and payment screens when logged in
      return null;
    },
    routes: [
      // Auth Routes (Outside Shell)
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 2: Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          // Tab 3: Subscriptions
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subscriptions',
                builder: (context, state) => const SubscriptionsScreen(),
              ),
            ],
          ),
          // Tab 4: Loans
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/loans',
                builder: (context, state) => const LoansScreen(),
              ),
            ],
          ),
          // Tab 5: Profile removed - moved to dashboard header
        ],
      ),
      
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),

      GoRoute(
        path: '/credit-health',
        builder: (context, state) => const CreditHealthScreen(),
      ),

      GoRoute(
        path: '/add-expense',
        parentNavigatorKey: _rootNavigatorKey, // Covers bottom nav
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            fullscreenDialog: true,
            child: AddExpenseScreen(
              initialAmount: extra?['amount'] as double?,
              initialTitle: extra?['title'] as String?,
              initialDate: extra?['date'] as DateTime?,
              scannedImagePath: extra?['scannedImagePath'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
       GoRoute(
        path: '/payment-status',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['sessionId'] ?? '';
          return PaymentStatusScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/sms-review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SmsReviewScreen(),
      ),
      GoRoute(
        path: '/surge-ai',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return MaterialPage(
            fullscreenDialog: true,
            child: const SurgeAIChatScreen(),
          );
        },
      ),
      GoRoute(
        path: '/add-subscription',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddSubscriptionScreen(),
      ),
      GoRoute(
        path: '/add-loan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddLoanScreen(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/security-setup',
        builder: (context, state) => const SecuritySetupScreen(),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Production Release Safety Checks
  BuildValidator.validate();
  PermissionComplianceScanner.scan();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  try {
    await ReminderNotificationService().initialize();
    await ReminderService().initialize();
  } catch (e) {
    print('Reminder service initialization error: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize Auto Tracking
    ref.read(autoTrackingInitializerProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger verification check for any active payment session
      // This is handled by the StreamProvider in PaymentStatusScreen, 
      // but we can add an extra explicit fetch here if needed.
      ref.read(securityStateProvider.notifier).onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      ref.read(securityStateProvider.notifier).onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Pro Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, 
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        // Overlay AppLockScreen when locked
        final securityState = ref.watch(securityStateProvider);
        final user = ref.watch(authStateProvider).value;
        // Only show lock screen if user is logged in AND app is locked
        final showLockScreen = user != null && securityState.isLocked;

        return Stack(
          children: [
            if (child != null) child,
            if (showLockScreen) 
              const Positioned.fill(child: AppLockScreen()),
          ],
        );
      },
    );
  }
}
