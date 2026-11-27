import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/api_error.dart';

/// Shown in place of a chart/section whose request failed, instead of a
/// spinner that never stops. [message] is the bloc's error message (already
/// "Không có kết nối mạng" / "Hệ thống đang gặp sự cố" / a backend message);
/// when empty, falls back to the system-problem message.
class ApiErrorPlaceholder extends StatelessWidget {
  const ApiErrorPlaceholder({super.key, this.message, this.height = 240});

  final String? message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Text(
        (message?.isNotEmpty ?? false) ? message! : apiErrorMessage(null),
        textAlign: TextAlign.center,
        style: TextStyle(color: R.color.color0xff636A6B, fontSize: 15),
      ),
    );
  }
}
