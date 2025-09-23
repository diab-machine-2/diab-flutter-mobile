import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/add_bmi_page.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/bmi_overview_page.dart';
import 'package:medical/src/widget/bmi/widget/bmi_height_picker.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

class BmiInputWaistConfirmDialog {
  static Future show(BuildContext context, {void Function()? onConfirmed}) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => _BmiInputWaistConfirmDialogView(
        onConfirmed: onConfirmed,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }
}

class _BmiInputWaistConfirmDialogView extends StatelessWidget {
  _BmiInputWaistConfirmDialogView({super.key, this.onConfirmed});

  final void Function()? onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.largeRadius),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close_rounded))),
              Icon(
                Icons.info_rounded,
                size: 64,
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                "iopppp",
                style: R.style.alertTitle,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "iopppp",
                style: R.style.normalTextStyle,
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedRoundedButton(
                      title: R.string.skip.tr(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: PrimaryRoundedButton(
                      title: "uiouoa",
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirmed?.call();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
