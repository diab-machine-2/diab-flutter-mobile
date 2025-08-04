import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';

class HealthConnectButton extends StatelessWidget {
  const HealthConnectButton({
    super.key,
    this.callback,
    this.margin,
  });

  final VoidCallback? callback;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    String healthIcon = Platform.isIOS
        ? R.drawable.logo_healthkit
        : R.drawable.ic_health_connect_input_btn;
    String healthTitle = Platform.isIOS
        ? R.string.connect_from_Apple_Health.tr()
        : R.string.connect_from_Health_Connect.tr();
    return InkWell(
      onTap: () {
        RequestHealthConnect.showModal(context, callback: callback ?? () {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: R.color.color0xffDFE4E4,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              healthIcon,
              // fit height to content
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                healthTitle,
                style: TextStyle(color: R.color.textDark, fontSize: 16),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: R.color.primaryGreyColor,
            ),
          ],
        ),
      ),
    );
  }
}
