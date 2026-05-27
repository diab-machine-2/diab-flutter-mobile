import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlucoseSyncCache {
  static const String _deviceUserCacheKey = 'glucose_device_user_cache';

  /// Lưu cache theo cặp (deviceId + userId + lastSyncTime)
  static Future<void> saveSyncCache({
    required String deviceId,
    required String userId,
    required DateTime lastSyncTime,
    String? deviceName,
    String? modelName,
    String? modelNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${_deviceUserCacheKey}_${deviceId}_$userId';
    final cacheData = {
      'deviceId': deviceId,
      'userId': userId,
      'lastSyncTime': lastSyncTime.toIso8601String(),
      'deviceName': deviceName,
      'modelName': modelName,
      'modelNumber': modelNumber,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(cacheKey, jsonEncode(cacheData));
    print(
        '💾 Saved device+user cache: Device=$deviceId, User=$userId, Time=${lastSyncTime.toIso8601String()}');
  }

  /// Lấy thời điểm sync cuối cùng cho cặp device+user cụ thể
  static Future<DateTime?> getLastSyncTime(
      String deviceId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${_deviceUserCacheKey}_${deviceId}_$userId';
    final cacheString = prefs.getString(cacheKey);
    if (cacheString != null) {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final syncTime = DateTime.parse(cacheData['lastSyncTime']);
      print(
          '📅 Last sync time for Device=$deviceId, User=$userId: ${syncTime.toIso8601String()}');
      return syncTime;
    }
    print('📅 No previous sync time found for Device=$deviceId, User=$userId');
    return null;
  }




  /// Xóa tất cả cache (khi reinstall app hoặc reset)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final deviceUserKeys =
        keys.where((key) => key.startsWith(_deviceUserCacheKey));
    for (final key in deviceUserKeys) {
      await prefs.remove(key);
    }
    print('🗑️ Cleared all glucose sync cache');
  }

  /// Kiểm tra xem có phải lần đầu mở app không
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('glucose_first_launch_completed');
  }

  /// Đánh dấu đã hoàn thành lần đầu mở app
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('glucose_first_launch_completed', true);
    print('💾 Marked first launch as completed');
  }

  /// Kiểm tra xem thiết bị có phải là Accu-Chek không
  static bool isAccuChekDevice(String? modelNumber) {
    if (modelNumber == null) return false;
    final accuChekModels = [
      '483', '484', '497', '498', '499', '500', '502',
      '685', // Accu Check Aviva Connect
      '479', '501', '503', '765', // Accu Check Performa Connect
      '912', '922', '923', '925', '926', '929', '930',
      '932', // Accu Check Guide
      '958', '959', '960', '961', '963', '964', '965', // Accu Check Instant
      '897', '898', '901', '902', '903', '904', '905', // Accu Check Guide Me
      '972', '973', '975', '976', '977', '978', '979',
      '980', // Accu Check Instant2
      '966', '967', '968', '969', '970', '971', // Accu Check Instant S
    ];
    return accuChekModels.contains(modelNumber);
  }

  /// Kiểm tra xem thiết bị có phải là Nipro không
  static bool isNiproDevice(String? modelNumber) {
    if (modelNumber == null) return false;
    return !isAccuChekDevice(modelNumber);
  }
}
