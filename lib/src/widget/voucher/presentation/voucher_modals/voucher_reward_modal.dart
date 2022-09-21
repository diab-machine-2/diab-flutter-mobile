import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/profile/delete_account/presentation/widgets/submit_button.dart';
import 'package:medical/src/widgets/button_widget.dart';

class VoucherModalReward extends StatelessWidget {
  const VoucherModalReward({Key? key}) : super(key: key);

  showModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return VoucherModalReward();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: R.color.white,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      content: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(R.drawable.voucher_reward),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      Text(
                        "Chúc mừng bạn đã nhận được voucher khuyến mãi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Giới thiệu bạn bè dùng app thành công bạn nhận được 1 voucher khuyến mãi.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff666666,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ButtonWidget(
                        title: R.string.view_voucher.tr(),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 15,
              top: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pop(context, true);
                },
                child: Image.asset(
                  R.drawable.ic_close,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[],
    );
  }
}
