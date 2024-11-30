import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widgets/button_widget.dart';

class BloodSugarFunctions {
  static void showModalAddData(BuildContext context) {
    Widget buildContentItem(
        String title, String subtitle, String iconPath, VoidCallback onPressed) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: Color(0xFFF2F6F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 72, height: 72),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      height: 24 / 15,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: R.color.primaryGreyColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, size: 24, color: R.color.primaryGreyColor),
          ],
        ),
      );
    }

    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 365 + MediaQuery.of(context).viewInsets.bottom / 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              child: Row(
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        R.string.choose_how_to_enter.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Build content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  buildContentItem(
                    'Kết nối máy đo đường huyết',
                    'Tự động nhập chỉ số một cách nhanh chóng và chính xác.',
                    R.drawable.im_guide_connectdevice,
                    () {
                      Navigator.pop(context);
                      BlocProvider.of<NiproBloc>(context).tryAutoConnect();
                    },
                  ),
                  const SizedBox(height: 16),
                  buildContentItem(
                    'Nhập thủ công',
                    'Nhập chỉ số đường huyết của bạn bằng cách nhập thủ công từ kết quả đo đã có sẵn',
                    R.drawable.im_glucose_input_manual,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
                          arguments: {'type': 'input'});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showModalAddDataV1(BuildContext context) async {
    String healthIcon = Platform.isIOS ? R.drawable.logo_healthkit : R.drawable.logo_healthConnect;
    String healthTitle = Platform.isIOS
        ? R.string.connect_from_Apple_Health.tr()
        : R.string.connect_from_Health_Connect.tr();
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      backgroundColor: R.color.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: hasHealthConnection == true ? 290 : 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
              child: Text(
                R.string.choose_how_to_enter.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: R.color.textDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  if (hasHealthConnection == false)
                    ButtonWidget(
                      isIconSvg: false,
                      icon: healthIcon,
                      backgroundColor: Color(0xFFE4FCF3),
                      textColor: Color(0xff249B92),
                      title: healthTitle,
                      onPressed: () => RequestHealthConnect.showModal(context,
                          callback: () => Navigator.pop(context)),
                    ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    icon: R.icons.ic_bluetooth,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Kết nối từ thiết bị',
                    onPressed: () {
                      Navigator.pop(context);
                      BlocProvider.of<NiproBloc>(context).tryAutoConnect();
                    },
                  ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    icon: R.icons.ic_tap,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Nhập thủ công',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
                          arguments: {'type': 'input'});
                    },
                  ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    backgroundColor: Color(0xFFF4F4F4),
                    textColor: Color(0xff172823),
                    title: 'Đóng',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
