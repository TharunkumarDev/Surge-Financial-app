import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true, // Important for floating effect
      bottomNavigationBar: _FloatingDock(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _FloatingDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _FloatingDock({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main navigation bar
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(
                icon: Icons.home_filled,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.insert_chart_rounded,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 56), // Space for center button
              _NavBarItem(
                icon: Icons.repeat_rounded,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.account_balance_wallet_rounded,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
        
        // Center floating AI button
        Positioned(
          bottom: 45,
          child: _CenterAIButton(),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isActive,
    this.isCenter = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppTheme.limeAccent : AppTheme.darkGreen;
    final color = isActive ? activeColor : (isDark ? Colors.white.withOpacity(0.4) : Colors.grey.withOpacity(0.4));
    final scale = isActive ? 1.1 : 1.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        transform: Matrix4.identity()..scale(scale),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}

class _CenterAIButton extends StatelessWidget {
  const _CenterAIButton();
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Haptic feedback
        HapticFeedback.mediumImpact();
        // Navigate to Surge AI chat
        context.push('/surge-ai');
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.premiumGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.limeAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              'assets/images/surge_logo.png',
              height: 52,
              width: 52,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.auto_awesome,
                color: AppTheme.darkGreen,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
