import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlucoseSyncCache {
  // Legacy keys for backward compatibility
  static const String _lastSyncTimeKey = 'glucose_last_sync_time';
  static const String _lastSyncDeviceKey = 'glucose_last_sync_device';

  // New keys for device+user specific cache
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

    // Tạo key duy nhất cho cặp device+user
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

  /// Kiểm tra xem có cần sync toàn bộ dữ liệu không
  static Future<bool> shouldFullSync(String deviceId, String userId) async {
    final lastSyncTime = await getLastSyncTime(deviceId, userId);

    // Nếu không có lịch sử sync cho cặp device+user này → full sync
    final needFullSync = lastSyncTime == null;

    print(
        '🔄 Sync strategy for Device=$deviceId, User=$userId: ${needFullSync ? 'FULL SYNC' : 'INCREMENTAL SYNC'}');
    if (!needFullSync) {
      print('📅 Last sync: ${lastSyncTime.toIso8601String()}');
    }

    return needFullSync;
  }

  /// Lấy thời điểm bắt đầu để sync incremental (từ thời điểm sync cuối + 1 giây)
  static Future<DateTime?> getIncrementalSyncStartTime(
      String deviceId, String userId) async {
    final lastSyncTime = await getLastSyncTime(deviceId, userId);
    if (lastSyncTime != null) {
      // Thêm 1 giây để tránh duplicate data
      final startTime = lastSyncTime.add(Duration(seconds: 1));
      print(
          '⏰ Incremental sync from: ${startTime.toIso8601String()} for Device=$deviceId, User=$userId');
      return startTime;
    }
    return null;
  }

  /// Lưu thời điểm đồng bộ thành công cuối cùng (legacy method for backward compatibility)
  static Future<void> saveLastSyncTime(DateTime syncTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, syncTime.toIso8601String());
    print('💾 Saved last sync time (legacy): ${syncTime.toIso8601String()}');
  }

  /// Lấy thời điểm đồng bộ thành công cuối cùng (legacy method for backward compatibility)
  static Future<DateTime?> getLegacyLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_lastSyncTimeKey);
    if (timeString != null) {
      final syncTime = DateTime.parse(timeString);
      print('📅 Last sync time (legacy): ${syncTime.toIso8601String()}');
      return syncTime;
    }
    print('📅 No previous sync time found (legacy)');
    return null;
  }

  /// Lưu thông tin thiết bị kết nối cuối cùng (legacy method for backward compatibility)
  static Future<void> saveLastSyncDevice({
    required String deviceId,
    required String deviceName,
    String? modelName,
    String? modelNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final deviceInfo = {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'modelName': modelName,
      'modelNumber': modelNumber,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_lastSyncDeviceKey, jsonEncode(deviceInfo));
    print('💾 Saved device info (legacy): $deviceName ($deviceId)');
  }

  /// Lấy thông tin thiết bị kết nối cuối cùng (legacy method for backward compatibility)
  static Future<Map<String, dynamic>?> getLastSyncDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceString = prefs.getString(_lastSyncDeviceKey);
    if (deviceString != null) {
      final deviceInfo = jsonDecode(deviceString) as Map<String, dynamic>;
      print(
          '📱 Last sync device (legacy): ${deviceInfo['deviceName']} (${deviceInfo['deviceId']})');
      return deviceInfo;
    }
    print('📱 No previous sync device found (legacy)');
    return null;
  }

  /// Kiểm tra xem thiết bị hiện tại có phải là thiết bị đã sync trước đó không (legacy method)
  static Future<bool> isSameDevice(String currentDeviceId) async {
    final lastDevice = await getLastSyncDevice();
    if (lastDevice == null) return false;

    final isSame = lastDevice['deviceId'] == currentDeviceId;
    print(
        '🔍 Device comparison (legacy): $currentDeviceId ${isSame ? '==' : '!='} ${lastDevice['deviceId']}');
    return isSame;
  }

  /// Xóa tất cả cache (khi reinstall app hoặc reset)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa legacy cache
    await prefs.remove(_lastSyncTimeKey);
    await prefs.remove(_lastSyncDeviceKey);

    // Xóa tất cả device+user cache
    final keys = prefs.getKeys();
    final deviceUserKeys =
        keys.where((key) => key.startsWith(_deviceUserCacheKey));
    for (final key in deviceUserKeys) {
      await prefs.remove(key);
    }

    print('🗑️ Cleared all glucose sync cache (legacy + device+user specific)');
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

    // Danh sách model numbers của Accu-Chek devices
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

    // Nếu không phải Accu-Chek thì có thể là Nipro hoặc thiết bị khác
    // Có thể thêm logic cụ thể hơn để identify Nipro devices nếu cần
    return !isAccuChekDevice(modelNumber);
  }

  /// Debug: In ra tất cả thông tin cache
  static Future<void> printCacheInfo() async {
    print('=== GLUCOSE SYNC CACHE INFO ===');
    final lastSyncTime = await getLegacyLastSyncTime();
    final lastDevice = await getLastSyncDevice();

    print('Legacy cache:');
    print('  Last sync time: ${lastSyncTime?.toIso8601String() ?? 'None'}');
    print('  Last device: ${lastDevice?['deviceName'] ?? 'None'}');
    print('  Device ID: ${lastDevice?['deviceId'] ?? 'None'}');
    print('  Model: ${lastDevice?['modelName'] ?? 'None'}');
    print('===============================');
  }
}
