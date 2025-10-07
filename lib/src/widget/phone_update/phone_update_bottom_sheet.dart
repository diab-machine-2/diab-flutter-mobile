import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class PhoneUpdateBottomSheet extends StatelessWidget {
  const PhoneUpdateBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              R.string.cap_nhat_so_dien_thoai.tr(),
              style: TextStyle(
                color: R.color.color0xff111515,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              R.string.giup_bao_ve_tai_khoan.tr(),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            // Illustration
            Image.asset(
              R.drawable.ic_phone_security,
              width: 120,
              height: 120,
            ),

            GapH(16),

            // Update Now Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, NavigatorName.update_phone_number);
              },
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientBottom
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.cap_nhat_ngay.tr(),
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Next Time Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              // Set the flag to false when user clicks "Next Time"
              PhoneValidationManager.resetShouldShowPhoneValidation();
              },
              child: Container(
                height: 44,
                width: double.infinity,
                child: Center(
                  child: Text(
                    R.string.lan_sau.tr(),
                    style: TextStyle(
                      color: R.color.color0xff5E6566,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PhoneUpdateBottomSheet(),
    );
  }
}

