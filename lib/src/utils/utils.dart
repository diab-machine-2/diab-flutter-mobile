import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import 'const.dart';

class Utils {
  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      Console.log('checkConnection Error', 'Internet not connect');
    }
    return false;
  }

  static String getNewTitle(String title) {
    if (title.length > 1) {
      var temp = title.substring(title.length - 1, title.length);
      var tempInt = 0;
      try {
        tempInt = int.parse(temp);
        tempInt = tempInt + 1;
      } catch (error) {}
      return title.substring(0, title.length - 1) + tempInt.toString();
    } else {
      return title;
    }
  }

  static void setStatusColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark));
  }

  // static void showSnackBar(BuildContext context, String text) {
  //   final snackBar = SnackBar(
  //     content: Text(text),
  //     backgroundColor: R.color.accentColor,
  //   );
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  static void onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  // static void showErrorSnackBar(BuildContext context, String text) {
  //   onWidgetDidBuild(() => showSnackBar(context, text));
  // }

  static String getTypeUrlLauncher(String url, int type) {
    switch (type) {
      case Const.TYPE_WEB:
        return url;
      case Const.TYPE_EMAIL:
        return "mailto:$url";
      case Const.TYPE_PHONE:
        return "tel:$url";
      case Const.TYPE_SMS:
        return "sms:$url";
    }
    return url;
  }

  static Future launchURL(String url) async {
    url = url.replaceAll(" ", "");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Console.log('launchURL Error', 'Đã có lỗi xảy ra');
    }
  }

  static bool isEmpty(Object? text) {
    if (text is String) return text.isEmpty;
    if (text is List) return text.isEmpty;
    return text == null;
  }

  static bool isEmptyArray(List list) {
    return list.isEmpty;
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();

  static Color parseStringToColor(String? color) {
    if (isEmpty(color))
      return R.color.white;
    else
      return Color(int.parse('0xff' + color!.substring(1)));
  }

  static String parseDateToString(DateTime? dateTime, String format) {
    String date = "";
    if (dateTime != null)
      try {
        date = DateFormat(format).format(dateTime);
      } on FormatException catch (e) {
        Console.log('parseDateToString Error', e.toString());
      }
    return date;
  }

  static String? parseStringDateToString(
      String? dateSv, String fromFormat, String toFormat) {
    String? date = dateSv;
    if (dateSv != null)
      try {
        date = DateFormat(toFormat, "en_US")
            .format(DateFormat(fromFormat).parse(dateSv));
      } on FormatException catch (e) {
        Console.log('parseStringDateToString Error', e.toString());
      }
    return date;
  }

  static Future showDialogTextTwoButton(
      {required BuildContext context,
      String? title,
      String? contentText,
      String? submitText,
      VoidCallback? submitCallback,
      bool dismissible: false}) {
    return showDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (context) {
          return AlertDialog(
              title: isEmpty(title) ? Text(title!) : null,
              content: Text(contentText!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(R.string.close.tr()),
                ),
                Visibility(
                  visible: isEmpty(submitText),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submitCallback!();
                    },
                    child: Text(submitText!),
                  ),
                )
              ]);
        });
  }

  static Future showDialogTwoButton(
      {required BuildContext context,
      String? title,
      Widget? contentWidget,
      String? submitText,
      VoidCallback? submitCallback,
      bool dismissible: false}) {
    return showDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (context) {
          return AlertDialog(
              title: title == null ? Text(title!) : null,
              content: contentWidget,
              actions: [
                // TextButton(
                //   onPressed: () => popDialog(context),
                //  // child: Text(R.string.close),
                // ),
                Visibility(
                  visible: isEmpty(submitText),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submitCallback!();
                    },
                    child: Text(submitText!),
                  ),
                )
              ]);
        });
  }

  static void showDialogTwoButtonAfterLayout(
      {BuildContext? context,
      String? title,
      Widget? contentWidget,
      List<Widget>? actions}) async {
    onWidgetDidBuild(() => showDialog(
        barrierDismissible: false,
        context: context!,
        builder: (context) {
          return AlertDialog(
              title: title == null ? Text(title!) : null,
              content: contentWidget,
              actions: actions);
        }));
  }

  static navigateNextFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static int? convertPriceToNumber(String price) {
    if (price == null) return null;
    String newPrice = price
        .replaceAll(" ", "")
        .replaceAll("đ", "")
        .replaceAll("₫", "")
        .replaceAll("\$", "")
        .replaceAll(",", "");
    try {
      return int.parse(newPrice);
    } catch (e) {
      Console.log('convertPriceToNumber Error', e.toString());
      return null;
    }
  }

  static String? formatMoney(dynamic amount) {
    if (amount == null) {
      return null;
    }

    if (amount is String) {
      amount = double.parse(amount);
    }
    return NumberFormat("#,##0₫").format(amount);
  }

  static void showToast(String text) {
    if (isEmpty(text))
      Fluttertoast.showToast(
        msg: text,
        backgroundColor: R.color.accentColor,
      );
  }

  // static Future updateBadge(int count) async {
  //   if (await FlutterAppBadger.isAppBadgeSupported()) {
  //     FlutterAppBadger.updateBadgeCount(count);
  //   }
  // }

  // static void showForegroundNotification(
  //     BuildContext context, String title, String text,
  //     { VoidCallback onTapNotification}) {
  //   showOverlayNotification((context) {
  //     return Card(
  //       margin: const EdgeInsets.symmetric(horizontal: 4),
  //       child: SafeArea(
  //         bottom: false,
  //         child: InkWell(
  //           onTap: () {
  //             OverlaySupportEntry.of(context).dismiss();
  //             onTapNotification();
  //           },
  //           child: ListTile(
  //             leading: SizedBox.fromSize(
  //                 size: const Size(40, 40),
  //                 child: ClipOval(
  //                   child: Image.asset(R.drawable.ic_logo),
  //                 )),
  //             title: Text(
  //               title,
  //               style: TextStyle(fontWeight: FontWeight.bold, color: R.color.black),
  //             ),
  //             subtitle: Text(
  //               text ,
  //               style: TextStyle(color: R.color.grey),
  //             ),
  //             trailing: IconButton(
  //                 icon: Icon(Icons.close, color: R.color.grey),
  //                 onPressed: () {
  //                   OverlaySupportEntry.of(context).dismiss();
  //                 }),
  //           ),
  //         ),
  //       ),
  //     );
  //   }, duration: Duration(milliseconds: 4000));
  // }

  static String getFileName(File file) {
    return basename(file.path);
  }

  static String base64Image(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  static String? getImageUrl(String? path, {String? host}) {
    if (isEmpty(path)) return null;
    return (host ?? getHostUrl()) + path!;
  }

  static Future<Map<String, dynamic>?> parseJson(String fileName) async {
    return jsonDecode(await rootBundle.loadString("assets/$fileName"));
  }

  static String convertVNtoText(String str) {
    str = str.replaceAll(RegExp(r'[à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ]'), 'a');

    str = str.replaceAll(RegExp(r'[è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ì|í|ị|ỉ|ĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳ|ý|ỵ|ỷ|ỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');

    str = str.replaceAll(RegExp(r'[À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ]'), 'A');
    str = str.replaceAll(RegExp(r'[È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ]'), 'E');
    str = str.replaceAll(RegExp(r'[Ì|Í|Ị|Ỉ|Ĩ]'), 'I');
    str = str.replaceAll(RegExp(r'[Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ]'), 'O');
    str = str.replaceAll(RegExp(r'[Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ]'), 'U');
    str = str.replaceAll(RegExp(r'[Ỳ|Ý|Ỵ|Ỷ|Ỹ]'), 'Y');
    str = str.replaceAll(RegExp(r'[Đ]'), 'D');
    return str;
  }

  static String getValueOfMonth(int month) {
    late String returnValue = '';
    String appLanguage = AppPreference().appLanguage;
    if (appLanguage == 'vi') return "Tháng $month";
    switch (month) {
      case 1:
        returnValue = "January";
        break;
      case 2:
        returnValue = "February";
        break;
      case 3:
        returnValue = "March";
        break;
      case 4:
        returnValue = "April";
        break;
      case 5:
        returnValue = "May";
        break;
      case 6:
        returnValue = "June";
        break;
      case 7:
        returnValue = "July";
        break;
      case 8:
        returnValue = "August";
        break;
      case 9:
        returnValue = "September";
        break;
      case 10:
        returnValue = "October";
        break;
      case 11:
        returnValue = "November";
        break;
      case 12:
        returnValue = "December";
        break;
    }
    return returnValue;
  }

  static String getMediaUrl(String url, String token) {
    if (isEmpty(url)) return url;
    return getHostUrl() + "api/" + url + "token=$token";
  }

  static String getHostUrl() {
    if (AppSettings.environment == "staging") {
      return Const.HOST_URL_STAGING;
    } else if (AppSettings.environment == "dev") {
      return Const.HOST_URL_DEV;
    } else {
      return Const.HOST_URL;
    }
  }

  static String getHostDocosanUrl() {
    if (AppSettings.environment == "product") {
      return Const.HOST_DOCOSAN_URL;
    } else {
      return Const.HOST_DOCOSAN_URL_STAGING;
    }
  }

  static String getDocosanDomain() {
    if (AppSettings.environment == "product") {
      return Const.HOST_DOCOSAN_DOMAIN;
    } else {
      return Const.HOST_DOCOSAN_DOMAIN_STAGING;
    }
  }

  static String getDocosanDomainUrl() {
    if (AppSettings.environment == "product") {
      return Const.HOST_DOCOSAN_DOMAIN_URL;
    } else {
      return Const.HOST_DOCOSAN_DOMAIN_STAGING_URL;
    }
  }

  static String showValue(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }

  static Color getColorByCode(String? code) {
    // if (code == Const.PRO)
    //   return R.color.yellow;
    // else if (code == Const.PREMIUM)
    //   return R.color.accentColor;
    return R.color.white;
  }

  // static Future updateBadge(int count) async {
  //   if (await FlutterAppBadger.isAppBadgeSupported()) {
  //     FlutterAppBadger.updateBadgeCount(count);
  //   }
  // }

  static String getDayInWeekTitle(int index) {
    if (index >= 0 && index < 6) return 'T${index + 2}';
    if (index == 6) return 'CN';
    return '';
  }

  static String getDayInWeekTitleFromTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .toLocal();
    return getDayInWeekTitle(date.weekday - 1);
  }

  static String getBMI({required double height, required double weight}) {
    if (height == 0) return '0';
    final double bmi = weight / pow(height / 100, 2);
    final num mod = pow(10.0, 1);
    return ((bmi * mod).round().toDouble() / mod).toString();
  }

  static int parseStringToInt(String text) {
    try {
      final int number = double.parse(text).toInt();
      return number;
    } catch (_) {
      return 0;
    }
  }

  static String capitalize(String value) {
    String returnValue =
        value.substring(0, 1).toUpperCase() + value.substring(1).toLowerCase();
    return returnValue;
  }

  // Kiểm tra trạng thái đang tiểu đường thai kỳ
  static bool isGestationalDiabetes() {
    bool result = false;
    var user = AppSettings.userInfo!;
    if (user.levelOfDiabetesRuleList != null) {
      int indexWhere = user.levelOfDiabetesRuleList!.indexWhere(
          (element) => element.selected == true && element.value == '3');
      return !indexWhere.isNegative;
    }
    return result;
  }

  static String getActivityIconDescription(ScheduleType scheduleType) {
    switch (scheduleType) {
      case ScheduleType.blood_pressure:
      case ScheduleType.blood_pressure_recommend:
        return R.string.blood_pressure.tr();
      case ScheduleType.blood_sugar:
      case ScheduleType.blood_sugar_recommend:
      case ScheduleType.schedule_glucose_recommend:
        return R.string.blood_sugar.tr();
      case ScheduleType.weight:
        return R.string.weight.tr();
      case ScheduleType.food:
      case ScheduleType.food_menu:
      case ScheduleType.food_recommend:
        return R.string.nutrition.tr();
      case ScheduleType.exercise:
      case ScheduleType.exercise_recommend:
        return R.string.exercise.tr();
      case ScheduleType.book_1_1:
      case ScheduleType.io_evaluate:
      case ScheduleType.output_assessment:
        return R.string.event.tr();
      case ScheduleType.survey:
      case ScheduleType.update_profile:
        return R.string.survey.tr();
      case ScheduleType.lesson:
      case ScheduleType.lesson_recommend:
        return R.string.knowledge.tr();
      case ScheduleType.book_1_n:
        return R.string.huong_dan.tr();
      case ScheduleType.custom:
      case ScheduleType.goal_setting_recommend:
        return R.string.target.tr();
      case ScheduleType.emotion:
        return R.string.cam_xuc.tr();
      case ScheduleType.schedule_recommend:
        return R.string.reminder.tr();
      case ScheduleType.hba1c_recommend:
        return R.string.hba1c.tr();
      case ScheduleType.height_recommend:
        return R.string.chieu_cao.tr();
      case ScheduleType.weight_recommend:
        return R.string.can_nang.tr();
      default:
        return "";
    }
  }

  static Color getActivityIconTextColor(ScheduleType scheduleType) {
    switch (scheduleType) {
      case ScheduleType.blood_pressure:
      case ScheduleType.blood_pressure_recommend:
        return R.color.blood_pressure_color;
      case ScheduleType.blood_sugar:
      case ScheduleType.blood_sugar_recommend:
        return R.color.blood_sugar_color;
      case ScheduleType.weight:
        return R.color.weight_color;
      case ScheduleType.food:
      case ScheduleType.food_menu:
      case ScheduleType.food_recommend:
        return R.color.nutrition_color;
      case ScheduleType.exercise:
      case ScheduleType.exercise_recommend:
        return R.color.exercise_color;
      case ScheduleType.book_1_1:
      case ScheduleType.output_assessment:
      case ScheduleType.io_evaluate:
        return R.color.event_color;
      case ScheduleType.survey:
        return R.color.survey_color;
      case ScheduleType.lesson:
      case ScheduleType.lesson_recommend:
        return R.color.lesson_color;
      case ScheduleType.update_profile:
        return R.color.survey_color;
      case ScheduleType.book_1_n:
        return R.color.knowledge_color;
      case ScheduleType.custom:
      case ScheduleType.goal_setting_recommend:
        return R.color.target_color;
      case ScheduleType.emotion:
        return R.color.emotion_color;
      case ScheduleType.schedule_recommend:
        return R.color.reminder_color;
      case ScheduleType.hba1c_recommend:
        return R.color.hba1c_color;
      case ScheduleType.schedule_glucose_recommend:
        return R.color.blood_sugar_color;
      case ScheduleType.height_recommend:
        return R.color.height_color;
      case ScheduleType.weight_recommend:
        return R.color.weight_color;
      default:
        return R.color.black;
    }
  }

  static BoxShadow getBoxShadowDropCard() {
    return BoxShadow(
      color: R.color.shadowColorNew.withOpacity(0.08),
      spreadRadius: 0,
      blurRadius: 8,
      offset: Offset(1, 2),
    );
  }

   static BoxShadow getBoxShadowDropButton() {
    return BoxShadow(
      color: R.color.shadowColorNew.withOpacity(0.08),
      spreadRadius: 0,
      blurRadius: 8,
      offset: Offset(2, -4),
    );
  }
}

extension Precision on double {
  double toPrecision(int fractionDigits) {
    num mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}
