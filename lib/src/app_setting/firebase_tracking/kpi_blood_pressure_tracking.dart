// ACTIVITY LIST (Vận động)
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class KpiBloodPressureTracking {
  static const String screenName = 'kpi_blood_pressure';
  static const String kpiName = 'Chỉ số Huyết áp';
  static const String screenClass = 'BloodPressureOverviewController';

  static Future<void> firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    AppSettings.currentScreenName = screenName;
  }

  // Nhấn Tab Chi tiết bên trong 1 KPI
  static Future<void> clickDetailTab() async {
    // await TrackingManager.analytics.logEvent(
    //   name: 'component_clicked',
    //   parameters: {
    //     "screen_name": screenName,
    //     "component_name": 'tab_kpi_detail',
    //     "object_type": screenName,
    //     "object_title": kpiName,
    //   },
    // );
  }

  // Chọn 1 item KPI từ danh sách trong Tab Chi Tiết
  static Future<void> clickKpiItem() async {
    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": screenName,
        "component_name": 'list_kpi_detail_item',
        "object_type": screenName,
        "object_title": kpiName,
      },
    );
  }
}
