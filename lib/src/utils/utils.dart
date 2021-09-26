import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:medical/res/R.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import 'const.dart';
import 'logger.dart';

class Utils {
  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      logger.d('Internet not connect');
    }
    return false;
  }

  static void setStatusColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark));
  }

  static void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: R.color.primaryColor,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static void onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      callback();
    });
  }

  static void showErrorSnackBar(BuildContext context, String text) {
    onWidgetDidBuild(() => showSnackBar(context, text));
  }

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
      logger.d('Đã có lỗi xảy ra');
    }
  }

  static bool isEmpty(Object? text) {
    if (text is String) return text.isEmpty;
    if (text is List) return text.isEmpty;
    return text == null;
  }

  static bool isEmptyArray(List list) {
    return list == null || list.isEmpty;
  }

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();

  static Color parseStringToColor(String color) {
    if (isEmpty(color))
      return R.color.white;
    else
      return Color(int.parse('0xff' + color.substring(1)));
  }

  static String parseDateToString(DateTime? dateTime, String format) {
    String date = "";
    if (dateTime != null)
      try {
        date = DateFormat(format).format(dateTime);
      } on FormatException catch (e) {
        logger.e(e.toString());
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
        logger.d(e.toString());
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
                FlatButton(
                  onPressed: () => popDialog(context),
                  child: Text(R.string.close.tr()),
                ),
                Visibility(
                  visible: isEmpty(submitText),
                  child: FlatButton(
                    onPressed: () {
                      popDialog(context);
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
                // FlatButton(
                //   onPressed: () => popDialog(context),
                //  // child: Text(R.string.close),
                // ),
                Visibility(
                  visible: isEmpty(submitText),
                  child: FlatButton(
                    onPressed: () {
                      popDialog(context);
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

  static Future pushAndRemoveUtilPage(BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        (Route<dynamic> route) => false);
  }

  static Future pushAndRemoveUtilKeepFirstPage(
      BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        ModalRoute.withName(Navigator.defaultRouteName));
  }

  static void popToFirst(BuildContext context) {
    return Navigator.of(context)
        .popUntil((Route<dynamic> route) => route.isFirst);
  }

  static void popByTime(BuildContext context, int count, {dynamic result}) {
    for (int i = 0; i < count - 1; i++) Navigator.of(context).pop();

    Navigator.of(context).pop(result);
  }

  static void popUtil(BuildContext context) {
    return Navigator.of(context).popUntil((Route<dynamic> route) => false);
  }

  static void popDialog(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  static Future navigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => widget));
  }

  static Future rootNavigatePage(BuildContext context, Widget widget) {
    return Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => widget));
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
      logger.e(e.toString());
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
    return (host ?? Const.HOST_URL) + path!;
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

  static String getMediaUrl(String url, String token) {
    if (isEmpty(url)) return url;
    return Const.API_URL + url + "token=$token";
  }

  static Color getColorByCode(String? code) {
    if (code == Const.PRO)
      return R.color.yellow;
    else if (code == Const.PREMIUM)
      return R.color.accentColor;
    return R.color.white;
  }

  // static Future updateBadge(int count) async {
  //   if (await FlutterAppBadger.isAppBadgeSupported()) {
  //     FlutterAppBadger.updateBadgeCount(count);
  //   }
  // }
}
