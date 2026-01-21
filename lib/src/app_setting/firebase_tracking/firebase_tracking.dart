import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class FirebaseTracking {
  // Register Infor (Nhập thông tin)

  // 1. Chọn tình trạng bệnh
  static Future<void> onClickSickYear(DateTime? sickYear) async {
    String objectValue = 'none';
    if (sickYear != null) {
      objectValue =
          convertToUTC(sickYear.millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy');
    }
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_sick_year',
        'object_value': objectValue
      },
    );
  }

  static Future<void> onSelectSickYear(DateTime? sickYear) async {
    String objectValue = 'none';
    if (sickYear != null) {
      objectValue =
          convertToUTC(sickYear.millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy');
    }
    await TrackingManager.logEvent(
      name: 'component_selected',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_sick_year',
        'object_value': objectValue
      },
    );
  }

  static Future<void> onClickSickState(
      CategoryItemUserModel? diabetesStatus) async {
    String objectValue = 'none';
    if (diabetesStatus != null) {
      objectValue = diabetesStatus.value!;
    }
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_sick_state',
        'object_value': objectValue,
      },
    );
  }

  static Future<void> onSelectSickState(
      CategoryItemUserModel? diabetesStatus) async {
    String objectValue = 'none';
    if (diabetesStatus != null) {
      objectValue = diabetesStatus.value!;
    }
    await TrackingManager.logEvent(
      name: 'component_selected',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_sick_state',
        'object_value': objectValue,
      },
    );
  }

  // 1. Chọn Ngày sinh
  static Future<void> onClickBirthDay(DateTime? date) async {
    String objectValue = 'none';
    if (date != null) {
      objectValue =
          convertToUTC(date.millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy');
    }
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_birth_day',
        'object_value': objectValue
      },
    );
  }

  static Future<void> onSelectBirthDay(DateTime? date) async {
    String objectValue = 'none';
    if (date != null) {
      objectValue =
          convertToUTC(date.millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy');
    }
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'register_information',
        'text_field_name': 'selector_register_infor_birth_day',
        'object_value': objectValue
      },
    );
  }
}
