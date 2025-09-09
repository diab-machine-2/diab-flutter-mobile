import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlucoseSyncCache {
  static const String _lastSyncTimeKey = 'glucose_last_sync_time';
  static const String _lastSyncDeviceKey = 'glucose_last_sync_device';
  
  /// Lưu thời điểm đồng bộ thành công cuối cùng
  static Future<void> saveLastSyncTime(DateTime syncTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, syncTime.toIso8601String());
    print('💾 Saved last sync time: ${syncTime.toIso8601String()}');
  }
  
  /// Lấy thời điểm đồng bộ thành công cuối cùng
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_lastSyncTimeKey);
    if (timeString != null) {
      final syncTime = DateTime.parse(timeString);
      print('📅 Last sync time: ${syncTime.toIso8601String()}');
      return syncTime;
    }
    print('📅 No previous sync time found');
    return null;
  }
  
  /// Lưu thông tin thiết bị kết nối cuối cùng
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
    print('💾 Saved device info: $deviceName ($deviceId)');
  }
  
  /// Lấy thông tin thiết bị kết nối cuối cùng
  static Future<Map<String, dynamic>?> getLastSyncDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceString = prefs.getString(_lastSyncDeviceKey);
    if (deviceString != null) {
      final deviceInfo = jsonDecode(deviceString) as Map<String, dynamic>;
      print('📱 Last sync device: ${deviceInfo['deviceName']} (${deviceInfo['deviceId']})');
      return deviceInfo;
    }
    print('📱 No previous sync device found');
    return null;
  }
  
  /// Kiểm tra xem thiết bị hiện tại có phải là thiết bị đã sync trước đó không
  static Future<bool> isSameDevice(String currentDeviceId) async {
    final lastDevice = await getLastSyncDevice();
    if (lastDevice == null) return false;
    
    final isSame = lastDevice['deviceId'] == currentDeviceId;
    print('🔍 Device comparison: $currentDeviceId ${isSame ? '==' : '!='} ${lastDevice['deviceId']}');
    return isSame;
  }
  
  /// Xóa tất cả cache (khi reinstall app hoặc reset)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncTimeKey);
    await prefs.remove(_lastSyncDeviceKey);
    print('🗑️ Cleared all glucose sync cache');
  }
  
  /// Kiểm tra xem có cần sync toàn bộ dữ liệu không
  static Future<bool> shouldFullSync(String currentDeviceId) async {
    final lastSyncTime = await getLastSyncTime();
    final isSameDevice = await GlucoseSyncCache.isSameDevice(currentDeviceId);
    
    // Nếu không có lịch sử sync hoặc thiết bị khác → full sync
    final needFullSync = lastSyncTime == null || !isSameDevice;
    
    print('🔄 Sync strategy: ${needFullSync ? 'FULL SYNC' : 'INCREMENTAL SYNC'}');
    if (!needFullSync) {
      print('📅 Last sync: ${lastSyncTime?.toIso8601String() ?? 'Unknown'}');
    }
    
    return needFullSync;
  }
  
  /// Lấy thời điểm bắt đầu để sync incremental (từ thời điểm sync cuối + 1 giây)
  static Future<DateTime?> getIncrementalSyncStartTime() async {
    final lastSyncTime = await getLastSyncTime();
    if (lastSyncTime != null) {
      // Thêm 1 giây để tránh duplicate data
      final startTime = lastSyncTime.add(Duration(seconds: 1));
      print('⏰ Incremental sync from: ${startTime.toIso8601String()}');
      return startTime;
    }
    return null;
  }
  
  /// Debug: In ra tất cả thông tin cache
  static Future<void> printCacheInfo() async {
    print('=== GLUCOSE SYNC CACHE INFO ===');
    final lastSyncTime = await getLastSyncTime();
    final lastDevice = await getLastSyncDevice();
    
    print('Last sync time: ${lastSyncTime?.toIso8601String() ?? 'None'}');
    print('Last device: ${lastDevice?['deviceName'] ?? 'None'}');
    print('Device ID: ${lastDevice?['deviceId'] ?? 'None'}');
    print('Model: ${lastDevice?['modelName'] ?? 'None'}');
    print('===============================');
  }
}
