import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';

Future<void> showHbA1cInputMethodModal(
  BuildContext context, {
  bool popPrevious = false,
  String? goalId,
}) async {
  // Check if user already has HbA1C data
  bool hasExistingData = await _checkExistingHbA1CData();

  if (hasExistingData) {
    // If user has existing data, navigate directly to manual input
    TrackingManager.trackEvent(
      'hba1c_select_method',
      'kpi_hba1c',
      params: {
        'method': 'manual',
        'has_existing_data': 'true',
      },
    );
    if (popPrevious) {
      Navigator.pop(context);
    }
    Navigator.pushNamed(context, NavigatorName.add_hba1c,
        arguments: {'type': 'input', 'goalId': goalId});
    return;
  }
  Widget buildContentItem(
      String title, String subtitle, String iconPath, VoidCallback onPressed) {
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
                  'Tự động nhập chỉ số HbA1c một cách nhanh chóng và chính xác.',
                  healthIcon,
                  () async {
                    TrackingManager.trackEvent(
                      'hba1c_select_method',
                      'kpi_hba1c',
                      params: {
                        'method': 'device',
                      },
                    );
                    Navigator.pop(context);
                    if (popPrevious) {
                      Navigator.pop(context);
                    }
                    // Show Health Connect/Apple Health connection modal
                    RequestHealthConnect.showModal(
                      context,
                      callback: () {
                        // After successful connection, user can input HbA1C manually
                        // or the data will be synced automatically from Health Connect
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                buildContentItem(
                  'Nhập thủ công',
                  'Nhập chỉ số HbA1c của bạn bằng cách nhập thủ công từ kết quả xét nghiệm đã có sẵn',
                  R.drawable.im_glucose_input_manual,
                  () async {
                    TrackingManager.trackEvent(
                      'hba1c_select_method',
                      'kpi_hba1c',
                      params: {
                        'method': 'manual',
                      },
                    );
                    Navigator.pop(context);
                    if (popPrevious) {
                      Navigator.pop(context);
                    }
                    Navigator.pushNamed(context, NavigatorName.add_hba1c,
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

/// Check if user has existing HbA1C data
Future<bool> _checkExistingHbA1CData() async {
  try {
    final homeModel = await AppSettings.getHome();
    if (homeModel != null &&
        homeModel.hbA1CIndex.index != null &&
        homeModel.hbA1CIndex.index! > 0) {
      return true;
    }
    return false;
  } catch (e) {
    // If there's any error, assume no existing data
    return false;
  }
}
