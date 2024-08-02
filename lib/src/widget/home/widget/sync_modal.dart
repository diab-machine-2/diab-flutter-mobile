import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class SyncAccountModal extends StatefulWidget {
  final VoidCallback onTapSync;
  final VoidCallback onTapCancel;

  SyncAccountModal({required this.onTapSync, required this.onTapCancel});

  @override
  _SyncAccountModalState createState() => _SyncAccountModalState();

  static void show(BuildContext context,
      {required VoidCallback onTapSync, required VoidCallback onTapCancel}) {
    showDialog(
      context: context,
      builder: (context) =>
          SyncAccountModal(onTapSync: onTapSync, onTapCancel: onTapCancel),
    );
  }
}

class _SyncAccountModalState extends State<SyncAccountModal> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: EdgeInsets.all(10), // Adjust padding to fit screen better
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Adjust the radius here
      ),
      child: Container(
        width: deviceWidth * 0.9,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(R.drawable.sync_account_theme),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Bạn đã từng dùng số điện thoại để đăng nhập DiaB chưa?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Text(
                  'Cập nhật số điện thoại đã từng sử dụng để đồng bộ thông tin và bảo mật tài khoản tốt hơn',
                  textAlign: TextAlign.center,
                  style: R.style.normalTextStyle),
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onTapCancel,
                  child: Container(
                    width: deviceWidth * 0.35,
                    height: 43,
                    decoration: BoxDecoration(
                      color: R.color.gray_btn,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Center(
                      child: Text(
                        R.string.not_yet.tr(),
                        style: TextStyle(
                          color: R.color.dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onTapSync,
                  child: Container(
                    height: 43,
                    width: deviceWidth * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4BB2AB),
                          Color(0xFF01857A),
                          Color(0xFF008479)
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        R.string.used_to.tr(),
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
