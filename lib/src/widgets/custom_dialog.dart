import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class CustomDialog {
  CustomDialog._();

  static bool _isShowLoading = false;

  static void showLoadingDialog(BuildContext context) {
    if (_isShowLoading) return;

    _isShowLoading = true;
    showGeneralDialog(
      context: Navigator.of(context, rootNavigator: true).context,
      barrierDismissible: false,
      barrierLabel: 'Loading',
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // kính mờ
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // nền bán trong suốt
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
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
      _isShowLoading = false;
      Navigator.pop(context);
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon lỗi
                      const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        title,
                        style: R.style.boldXXLargeStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: R.style.normalTextStyle.neutral3,
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
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
                        style: R.style.boldXXLargeStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: R.style.normalTextStyle.neutral3,
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

  static void showConfirmDialog(
    BuildContext context, {
    String title = "Xác nhận",
    String message = "",
    Function()? onPrimaryButtonTap,
    Function()? onSecondaryButtonTap,
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
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
                        style: R.style.boldXXLargeStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: R.style.normalTextStyle.neutral3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Nút Đóng
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedRoundedButton(
                                title: 'Đóng',
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  onSecondaryButtonTap?.call();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: PrimaryRoundedButton(
                                title: 'Xác nhận',
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  onPrimaryButtonTap?.call();
                                },
                              ),
                            ),
                          ],
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

  static void showDeleteConfirmDialog(
    BuildContext context, {
    String title = "Xác nhận",
    String message = "",
    Function()? onPrimaryButtonTap,
    Function()? onSecondaryButtonTap,
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // kính mờ
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // nền liquid glass
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon thành công
                      Image.asset(
                        R.drawable.ic_x,
                        width: 48,
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        title,
                        style: R.style.boldXXLargeStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        message,
                        style: R.style.normalTextStyle.neutral3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Nút Đóng
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedRoundedButton(
                                title: 'Đóng',
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  onSecondaryButtonTap?.call();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: PrimaryRoundedButton(
                                title: 'Xóa',
                                color: AppColors.red,
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  onPrimaryButtonTap?.call();
                                },
                              ),
                            ),
                          ],
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
