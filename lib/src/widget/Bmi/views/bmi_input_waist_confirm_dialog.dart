import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

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
                color: AppColors.neutral5,
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                R.string.notInputWaistWarning.tr(),
                style: R.style.alertTitle,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                R.string.notInputWaistWarningDes.tr(),
                style: R.style.normalTextStyle.neutral4,
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
                      title: R.string.inputRightNow.tr(),
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
