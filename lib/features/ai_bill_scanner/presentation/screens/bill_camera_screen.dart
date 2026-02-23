import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../expense/data/expense_repository.dart';
import '../../../expense/domain/expense_model.dart';
import '../../domain/models/scanned_receipt.dart';
import '../../providers/bill_scanner_providers.dart';
import 'scan_result_screen.dart';
import '../../../../core/theme/design_system.dart';

class BillCameraScreen extends ConsumerStatefulWidget {
  const BillCameraScreen({super.key});

  @override
  ConsumerState<BillCameraScreen> createState() => _BillCameraScreenState();
}

class _BillCameraScreenState extends ConsumerState<BillCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final hasPermission = await _requestPermission(source);
    if (!hasPermission) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Optimize size
      );

      if (image == null) return;

      setState(() => _isProcessing = true);

      // Process
      final File file = File(image.path);
      final repository = ref.read(billScannerRepositoryProvider);
      final receipt = await repository.scanReceipt(file);

      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Auto-Save Rule: >80% confidence
        if (receipt.confidenceScore >= 0.8 && receipt.totalAmount > 0) {
          await _autoSaveExpense(receipt);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanResultScreen(receipt: receipt),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error scanning receipt: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
         // Android 13+ (SDK 33) requires separate permission
         // But permission_handler handles this internal check usually or we can use photos
         // For SDK 35 target, we should check READ_MEDIA_IMAGES if possible or just photos
         permission = Permission.photos;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();
    
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Required"),
            content: Text(
              source == ImageSource.camera 
                  ? "Camera access is needed to scan bills." 
                  : "Photo library access is needed to select bills."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("Settings"),
              ),
            ],
          ),
        );
      }
      return false;
    }
    return false;
  }



  Future<void> _autoSaveExpense(ScannedReceipt receipt) async {
    try {
      final expenseRepo = await ref.read(expenseRepositoryProvider.future);
      
      final expense = ExpenseItem()
        ..title = receipt.merchantName.isNotEmpty ? receipt.merchantName : "Scanned Receipt"
        ..amount = receipt.totalAmount
        ..date = receipt.date ?? DateTime.now()
        ..category = ExpenseCategory.shopping // Default AI category
        ..isRecurring = false
        ..note = "Auto-generated via Bill Scanner"
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..deviceId = "unknown";
        // ..note = "Auto-generated via Bill Scanner"; // Optional

      await expenseRepo.addExpense(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense Auto-Saved! ⚡"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // Go back to Home
      }
    } catch (e) {
      // Fallback to manual review if save fails
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanResultScreen(receipt: receipt),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Receipt")),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Analyzing Receipt..."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: AppTheme.greyText),
                  const SizedBox(height: 32),
                  _buildScanButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icons.camera_alt,
                    label: "Take Photo",
                    primary: true,
                  ),
                  const SizedBox(height: 16),
                  _buildScanButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icons.photo_library,
                    label: "Upload from Gallery",
                    primary: false,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScanButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool primary,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppTheme.darkGreen : Colors.white,
          foregroundColor: primary ? Colors.white : AppTheme.darkGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: primary ? null : const BorderSide(color: AppTheme.darkGreen),
        ),
      ),
    );
  }
}
