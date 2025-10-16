import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_height_picker.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class BmiHeightInputDialog {
  static Future show(
    BuildContext context, {
    Function(double height)? onConfirmed,
    int? initialHeight,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => _BmiHeightInputDialogView(
        initialHeight: initialHeight,
        onConfirmed: onConfirmed,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }
}

class _BmiHeightInputDialogView extends StatefulWidget {
  const _BmiHeightInputDialogView({
    super.key,
    this.onConfirmed,
    this.initialHeight,
  });

  @override
  State<_BmiHeightInputDialogView> createState() =>
      _BmiHeightInputDialogViewState();

  final Function(double height)? onConfirmed;
  final int? initialHeight;
}

class _BmiHeightInputDialogViewState extends State<_BmiHeightInputDialogView> {
  int _height = 0;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.chieu_cao.tr(),
                style: R.style.alertTitle,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                R.string.inputHeightWarning.tr(),
                style: R.style.normalTextStyle,
              ),
              SizedBox(
                  height: 164,
                  child: BmiHeightPicker(
                    initialValue: widget.initialHeight,
                    onChanged: (height) => _height = height,
                  )),
              const SizedBox(
                height: 12,
              ),
              PrimaryRoundedButton(
                title: R.string.next_lesson,
                onPressed: () async {
                  Navigator.pop(context);
                  widget.onConfirmed?.call(_height.toDouble());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
