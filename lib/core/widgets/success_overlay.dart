import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';

class SuccessOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onFinished;

  const SuccessOverlay({
    super.key,
    this.message = 'Successful',
    required this.onFinished,
  });

  static void show(BuildContext context, {String message = 'Successful', required VoidCallback onFinished}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => SuccessOverlay(
        message: message,
        onFinished: () {
          Navigator.of(context).pop();
          onFinished();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Start the timer to dismiss
    Future.delayed(const Duration(milliseconds: 2000), onFinished);

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.limeAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.limeAccent.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.darkGreen,
                size: 80,
              ),
            )
            .animate()
            .scale(
              duration: 600.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
            )
            .shimmer(
              duration: 1200.ms,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              style: AppTheme.heading2.copyWith(
                color: Colors.white,
                letterSpacing: 1.2,
                fontSize: 28,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
