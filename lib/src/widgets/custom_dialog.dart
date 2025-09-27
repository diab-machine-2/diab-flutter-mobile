import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class CustomDialog {
  CustomDialog._();

  static bool _isShowLoading = false;

  static void showLoadingDialog(BuildContext context) {
    if (_isShowLoading) return;

    _isShowLoading = true;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Loading',
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // kính mờ
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // nền bán trong suốt
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: R.color.mainColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang xử lý…',
                        style: TextStyle(
                          color: AppColors.neutral3,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      _isShowLoading = false;
    });
  }

  static void hideLoadingDialog(BuildContext context) {
    if (_isShowLoading) {
      Navigator.pop(context);
      _isShowLoading = false;
    }
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    String title = "Lỗi",
    String message = "",
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Error',
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon lỗi
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Nút Đóng
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Text('Đóng'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void showSuccessDialog(
    BuildContext context, {
    String title = "Thành công",
    String message = "",
    Function()? onPrimaryButtonTap,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon thành công
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Nút Đóng
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryRoundedButton(
                          title: 'Đóng',
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            onPrimaryButtonTap?.call();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
