import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';

class DeviceInfoService {
  final SharedPreferences prefs;
  static const String _deviceIdKey = 'device_unique_id';

  DeviceInfoService(this.prefs);

  String getDeviceId() {
    String? id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      prefs.setString(_deviceIdKey, id);
    }
    return id;
  }
}

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
    data: (p) => p,
    orElse: () => throw Exception('SharedPreferences not initialized'),
  );
  return DeviceInfoService(prefs);
});
