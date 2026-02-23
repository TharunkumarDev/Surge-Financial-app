import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../providers/security_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt to authenticate immediately when the screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAuth();
    });
  }

  Future<void> _triggerAuth() async {
    final success = await ref.read(securityStateProvider.notifier).unlockApp();
    if (success && mounted) {
      // Logic handled by state change
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Optional: Minimize app on back press
        // SystemNavigator.pop(); 
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Gradient / Image
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
                gradient: isDark ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkBackground,
                    Color(0xFF0F1C15), // Very dark green hint
                    AppTheme.darkBackground,
                  ],
                ) : null,
              ),
            ),
            
            // Blurred Backdrop (Glassmorphism)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.1),
                ),
              ),
            ),
  
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Premium Lock Icon Container
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isDark 
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.limeAccent.withOpacity(0.2),
                                AppTheme.limeAccent.withOpacity(0.05),
                              ],
                            ),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.limeAccent.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.lock_open_rounded, // or lock_rounded
                        size: 64,
                        color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack)
                     .shimmer(duration: 1500.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.5)),
                    
                    const SizedBox(height: 48),
                    
                    // Text Content
                    Text(
                      "Locked",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn().moveY(begin: 20, end: 0, delay: 200.ms),
  
                    const SizedBox(height: 12),
                    
                    Text(
                      "Authenticate to access your\nfinancial dashboard",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white60 : AppTheme.greyText,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
  
                    const SizedBox(height: 64),
  
                    // Unlock Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _triggerAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                          foregroundColor: isDark ? AppTheme.darkGreen : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          shadowColor: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fingerprint_rounded, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              "Unlock with Face ID / PIN",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0)
                     .boxShadow(
                        begin: BoxShadow(color: Colors.transparent, blurRadius: 0, spreadRadius: 0),
                        end: BoxShadow(
                          color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                        delay: 600.ms,
                        duration: 500.ms,
                      ),
                    
                    const Spacer(),
                    
                    // Forgot / Logout
                     TextButton(
                       onPressed: () async {
                         final repo = await ref.read(authRepositoryProvider.future);
                         await repo.signOut();
                         // Lock state will be hidden by main.dart logic since user becomes null
                       },
                       child: Text(
                         "Sign Out", 
                         style: TextStyle(
                           color: isDark ? Colors.white30 : Colors.grey[400],
                           fontWeight: FontWeight.w600,
                           fontSize: 14,
                         ),
                       ),
                     ).animate().fadeIn(delay: 1000.ms),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
