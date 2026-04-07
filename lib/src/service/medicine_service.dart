import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../modal/medicine/daily_medicine_model.dart';
import '../repo/medicine/medicine_client.dart';

class MedicineScheduleService {
  static final MedicineScheduleService _instance = MedicineScheduleService._();
  factory MedicineScheduleService() => _instance;
  MedicineScheduleService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // init local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // 🔹 Android plugin để tạo channel + xin quyền
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Tạo channel chính cho thuốc
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'high_importance_channel',
        'Medicine Reminder',
        description: 'Nhắc uống thuốc',
        importance: Importance.max,
      ),
    );
    print('Create notification channel high_importance_channel');

    // Xin quyền (Android 13+)
    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();

    // init Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Đăng ký job chạy mỗi ngày
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 1); // 1:00 sáng hôm nay
    final firstRun = now.isAfter(target) ? target.add(Duration(days: 1)) : target;
    final delay = firstRun.difference(now);

    await Workmanager().registerPeriodicTask(
      "daily-fetch",
      "fetchMedicinesAtNight",
      frequency: Duration(days: 1),
      initialDelay: delay,
    );
  }

  /// xoá tất cả notification hôm nay
  Future<void> clearTodaySchedules() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// tạo notification theo danh sách thuốc
  Future<void> createTodaySchedules(List<DailyMedicineModel> daily) async {
    for (var med in daily) {
      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Medicine Reminder',
        channelDescription: 'Nhắc uống thuốc',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        10,
        "Nhắc uống thuốc",
        "Đến giờ uống: ${med.name}",
        tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.local,
          med.appointmentDate * 1000,
        ),
        details,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print("Scheduled: ${med.appointmentDate} (${tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local,
        med.appointmentDate * 1000,
      )})");
    }
  }

  /// call api lấy lịch dùng thuốc
  Future<List<DailyMedicineModel>> fetchMedicineSchedulesFromApi() async {
    final medicineClient = MedicineClient();
    final currentDateTime = DateTime.now();
    final today = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, 7);
    final medicineSchedule = await medicineClient.fetchMedicineScheduleByDate(timestamp: (today.millisecondsSinceEpoch / 1000).round());
    return medicineSchedule.daily;
  }

  /// usecase: gọi khi user thao tác thêm/xoá/sửa đơn thuốc
  Future<void> refreshTodaySchedules() async {
    //final daily = await fetchMedicineSchedulesFromApi();
    final daily = [
      DailyMedicineModel(
        id: "1f901e7c-fac3-47f4-7787-08ddf43abdc5",
        accountId: "deaf7575-217f-4bfc-a536-2d169747b6f1",
        name: "Thuốc nổ",
        type: 34,
        appointmentDate: 1758452700,
        targetSchedulerId: null,
        dayInAgenda: null,
        dayInPackage: null,
        weekInAgenda: null,
        packageAccountTransactionId: "dbabbd0e-30c8-4dfd-fa42-08ddafd2c982",
        weekInPackage: null,
        executeType: 0,
        executeDayTimes: 1,
        actualExecuteDayTimes: 0,
        completedDate: null,
        surveyId: null,
        lessonId: null,
        exerciseMovementId: null,
        calendarId: null,
        prescriptionId: "53232d92-b46c-4d64-81c5-08ddf43abda4",
        medicationId: "b212da3a-7e06-419c-b5b3-22d7e605d0af",
        description: null,
        data: null,
        state: 3,
        targetScheduler: null,
        exerciseMovement: null,
        lesson: null,
        survey: null,
        calendar: null,
        prescriptionName: "đơn thuốc hai",
        moment: 3,
        dosage: 1.0,
        dosageUnit: "viên"
      ),
    ];
    await clearTodaySchedules();
    await createTodaySchedules(daily);
  }

  /// usecase: gọi từ Workmanager lúc 1h sáng
  Future<void> refreshSchedulesAtNight() async {
    final now = DateTime.now();
    if (now.hour == 1) {
      final daily = await fetchMedicineSchedulesFromApi();
      await clearTodaySchedules();
      await createTodaySchedules(daily);
    }
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'med_channel',
      'Test Channel',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(minutes: 2)); // 06:54:00 +07

    print("Now: $now (${now.millisecondsSinceEpoch ~/ 1000})");
    print("Scheduled: $scheduled (${scheduled.millisecondsSinceEpoch ~/ 1000})");

    final notificationId = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + Random().nextInt(1000);

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final permissionGranted = await androidPlugin?.requestExactAlarmsPermission();
    print("Exact alarm permission granted: $permissionGranted");

    // Truyền thông tin notification qua WorkManager
    final inputData = <String, dynamic>{
      'notificationId': notificationId,
      'title': 'Test Notification',
      'body': 'Thông báo sau 2 phút',
      'scheduled': scheduled.millisecondsSinceEpoch,
    };

    try {
      await Workmanager().registerOneOffTask(
        "testNotification_$notificationId",
        "testNotification",
        initialDelay: scheduled.difference(now),
        inputData: inputData,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: false,
        ),
      );
      print("Scheduled WorkManager task with ID: testNotification_$notificationId at $scheduled");
    } catch (e) {
      print("Error scheduling WorkManager task: $e");
    }
  }

  Future<void> showTestNotification2() async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Test Channel',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      10,
      'Test Notification',
      'Nếu bạn thấy cái này thì notification đang hoạt động.',
      notificationDetails,
    );
  }

  int getNotificationId(String medicineId, int appointmentDate) {
    // hashCode trả về int 64-bit, cần ép về int32 cho an toàn
    final hash = medicineId.hashCode ^ appointmentDate.hashCode;
    return hash & 0x7FFFFFFF; // ép về số dương 32-bit
  }

}

/// hàm entrypoint cho Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final service = MedicineScheduleService();
    // Khởi tạo lại plugin trong background
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await service._flutterLocalNotificationsPlugin.initialize(initSettings);

    if (task == "fetchMedicinesAtNight") {
      await service.refreshSchedulesAtNight();
    } else if (task.startsWith("medicine_") || task.startsWith("testNotification_")) {
      final notificationId = inputData?['notificationId'] as int?;
      final title = inputData?['title'] as String?;
      final body = inputData?['body'] as String?;
      final scheduledMs = inputData?['scheduled'] as int?;
      if (notificationId != null && title != null && body != null && scheduledMs != null) {
        final scheduled = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, scheduledMs);
        const androidDetails = AndroidNotificationDetails(
          'med_channel',
          'Test Channel',
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        );
        const notificationDetails = NotificationDetails(android: androidDetails);

        final now = tz.TZDateTime.now(tz.local);
        if (now.isAfter(scheduled) || now.isAtSameMomentAs(scheduled)) {
          await service._flutterLocalNotificationsPlugin.show(
            notificationId,
            title,
            body,
            notificationDetails,
          );
          print("Displayed notification with ID: $notificationId at $now"); // Debug
        }
      }
    }
    return Future.value(true);
  });
}
