import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/bmi_input_text_field.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class BmiGoalWeightInputDialog {
  static Future show(
    BuildContext context, {
    Function(double goal)? onConfirmed,
    double? currentGoal,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => _BmiGoalWeightInputDialogView(
        currentGoal: currentGoal,
        onConfirmed: onConfirmed,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }
}

class _BmiGoalWeightInputDialogView extends StatefulWidget {
  const _BmiGoalWeightInputDialogView({
    super.key,
    this.onConfirmed,
    this.currentGoal,
  });

  @override
  State<_BmiGoalWeightInputDialogView> createState() =>
      _BmiGoalWeightInputDialogViewState();

  final Function(double goal)? onConfirmed;
  final double? currentGoal;
}

class _BmiGoalWeightInputDialogViewState
    extends State<_BmiGoalWeightInputDialogView> {
  double _weightGoal = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentGoal?.toString() ?? "";
  }

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
                R.string.muc_tieu_can_nang.tr(),
                style: R.style.alertTitle,
              ),
              const SizedBox(
                height: 12,
              ),
              BmiInputTextField(
                hintText: "50",
                suffixText: "kg",
                controller: _controller,
                onChanged: (value) {
                  if (double.tryParse(value) != null) {
                    _weightGoal = double.tryParse(value)!;
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedRoundedButton(
                      title: R.string.cancel.tr(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: PrimaryRoundedButton(
                      title: R.string.save.tr(),
                      onPressed: () async {
                        Navigator.pop(context);
                        widget.onConfirmed?.call(_weightGoal);
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
