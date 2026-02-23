import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/scanner_service.dart';
import '../../expense/presentation/add_expense_screen.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../wallet/data/wallet_repository.dart'; // For InsufficientPermissionException
import '../../subscription/presentation/widgets/upgrade_dialog.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _scannerService = ScannerService();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Background Gradient Overlay
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.darkGreen.withValues(alpha: 0.15),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Premium Icon Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppTheme.limeAccent : AppTheme.darkGreen).withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.document_scanner_rounded,
                      size: 56,
                      color: isDark ? AppTheme.limeAccent : AppTheme.darkGreen,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(duration: const Duration(milliseconds: 2000), begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
                  .then()
                  .scale(duration: const Duration(milliseconds: 2000), begin: const Offset(1.05, 1.05), end: const Offset(1, 1)),

                  const SizedBox(height: 40),

                  // Typography
                  Text(
                    "Bill Scanner",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final tier = ref.watch(currentSubscriptionTierProvider);
                        final sub = ref.watch(currentSubscriptionProvider).value;
                        final captures = sub?.billCapturesThisMonth ?? 0;
                        
                        String limitText = "Capture a bill to automatically extract details";
                        // Simplify text logic for cleaner UI
                        if (tier == SubscriptionTier.basic) {
                          limitText = "${10 - captures} captures remaining";
                        } else if (tier == SubscriptionTier.free) {
                          limitText = "Upgrade to capture bills";
                        }

                        return Text(
                          limitText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                            height: 1.5,
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Action Buttons
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.limeAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : () => _scanBill(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: _isScanning 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: AppTheme.darkGreen, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: AppTheme.darkGreen),
                              const SizedBox(width: 8),
                              Text(
                                "Open Camera",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkGreen,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: _isScanning ? null : () => _scanBill(ImageSource.gallery),
                    icon: Icon(
                      Icons.photo_library_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    label: Text(
                      "Choose from Gallery",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBill(ImageSource source) async {
    final sub = ref.read(currentSubscriptionProvider).value;
    final tier = ref.read(currentSubscriptionTierProvider);
    final captures = sub?.billCapturesThisMonth ?? 0;
    final entitlement = ref.read(entitlementServiceProvider);

    if (!entitlement.canCaptureBill(tier, captures)) {
      showDialog(
        context: context,
        builder: (context) => UpgradeDialog(
          featureName: 'Bill Capture',
          minimumTier: tier == SubscriptionTier.free ? SubscriptionTier.basic : SubscriptionTier.pro,
        ),
      );
      return;
    }

    setState(() => _isScanning = true);

    try {
      // Step 1: Pick Image
      final imageFile = await _scannerService.pickImage(source: source);
      if (imageFile == null) {
        setState(() => _isScanning = false);
        return; // User cancelled
      }

      // Step 2: Process OCR
      final billDetails = await _scannerService.scanBill(imageFile);

      setState(() => _isScanning = false);

      // Step 3: Navigate to Add Expense with pre-filled data AND scanned image
      if (mounted) {
        context.push('/add-expense', extra: {
          'amount': billDetails.amount,
          'title': billDetails.merchantName,
          'date': billDetails.date,
          'scannedImagePath': imageFile.path, // Pass the scanned image
        });
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error scanning bill: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }
}
