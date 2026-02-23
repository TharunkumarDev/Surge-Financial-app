import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker_pro/core/theme/design_system.dart';

class UpiService {
  static const String upiId = "tharunkarthi297@okaxis"; 
  static const String merchantName = "Surge Tracker";
  
  static Future<bool> launchUpiIntent({
    required String amount,
    required String transactionId,
    required String appPackage,
  }) async {
    // Construct UPI URI
    final String upiUri = 'upi://pay?pa=$upiId&pn=$merchantName&am=$amount&cu=INR&tr=$transactionId';
    
    // For Android, we can try to launch the intent specifically for the selected app
    // standard url_launcher with upi:// usually triggers the app chooser.
    // To target specific apps, some developers use the package name if the launcher supports it.
    
    final Uri uri = Uri.parse(upiUri);
    
    try {
      // We use LaunchMode.externalNonBrowserApplication to ensure it opens in the UPI app
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static String getPackageName(String appName) {
    switch (appName.toLowerCase()) {
      case 'google pay':
        return 'com.google.android.apps.nbu.paisa.user';
      case 'phonepe':
        return 'com.phonepe.app';
      case 'paytm':
        return 'net.one97.paytm';
      default:
        return '';
    }
  }
}
