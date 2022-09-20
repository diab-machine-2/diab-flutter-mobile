import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class VoucherModalReward extends StatelessWidget {
  const VoucherModalReward({Key? key}) : super(key: key);

  showModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return VoucherModalReward();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: R.color.greenbg,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child:
                      Image.asset(R.drawable.ic_close, width: 36, height: 36),
                ),
              ],
            ),
            Image.asset(R.drawable.img_question, width: 200, height: 200),
            SizedBox(height: 16),
            Text(
              R.string.send_question_success.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              R.string.response_as_soon_as_possible.tr(),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: R.color.textDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      actions: <Widget>[],
    );
  }
}
