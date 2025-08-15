import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';

class BloodPressureFunctions {
  static void showModalAddData(BuildContext context,
      {bool popPrevious = false, String? goalId}) {
    Widget buildContentItem(String title, String subtitle, String iconPath,
        VoidCallback onPressed) {
      return InkWell(
        onTap: onPressed,
        child: Container(
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
              Icon(Icons.chevron_right,
                  size: 24, color: R.color.primaryGreyColor),
            ],
          ),
        ),
      );
    }

    // TODO: BLOOD PRESSURE
    // TrackingManager.trackEvent(
    //   'glucose_add_start',
    //   'kpi_glucose',
    //   params: {
    //     'cta_button_name': 'cta_add_glucose',
    //   },
    // );

    String healthIcon = Platform.isIOS
        ? R.drawable.logo_healthkit
        : R.drawable.logo_healthConnect;
    String healthTitle = Platform.isIOS
        ? R.string.connect_from_Apple_Health.tr()
        : R.string.connect_from_Health_Connect.tr();

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                    healthTitle,
                    'Tự động nhập chỉ số một cách nhanh chóng và chính xác.',
                    healthIcon,
                    () async {
                      if (await AppSettings.getLastOpenedBloodPressureInputType() == null) {
                        AppSettings.setLastOpenedBloodPressureInputType('device');
                      }
                      // TODO: BLOOD PRESSURE
                      // TrackingManager.trackEvent(
                      //   'glucose_select_method',
                      //   'kpi_glucose',
                      //   params: {
                      //     'method': 'device',
                      //   },
                      // );
                      Navigator.pop(context);
                      if (popPrevious) {
                        Navigator.pop(context);
                      }
                      BlocProvider.of<NiproBloc>(context).tryAutoConnect();
                    },
                  ),
                  const SizedBox(height: 16),
                  buildContentItem(
                    'Nhập thủ công',
                    'Nhập chỉ số huyết áp của bạn bằng cách nhập thủ công từ kết quả đo đã có sẵn',
                    R.drawable.im_bloodpressure_input_manual,
                    () async {
                      if (await AppSettings.getLastOpenedBloodPressureInputType() == null) {
                        AppSettings.setLastOpenedBloodPressureInputType('manual');
                      }
                      // TrackingManager.trackEvent(
                      //   'glucose_select_method',
                      //   'kpi_glucose',
                      //   params: {
                      //     'method': 'manual',
                      //   },
                      // );
                      Navigator.pop(context);
                      if (popPrevious) {
                        Navigator.pop(context);
                      }
                      Navigator.pushNamed(
                          context, NavigatorName.add_blood_pressure,
                          arguments: {'type': 'input', 'goalId': goalId});
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
}
