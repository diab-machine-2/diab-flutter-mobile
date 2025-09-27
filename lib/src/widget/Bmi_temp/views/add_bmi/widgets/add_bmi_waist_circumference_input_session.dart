import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/bmi_input_text_field.dart';

class AddBmiWaistCircumferenceInputSession extends StatelessWidget {
  const AddBmiWaistCircumferenceInputSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.waist.tr(),
            style: R.style.boldXLargeStyle,
          ),
          _WaistCircumferenceInputTextField(),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

class _WaistCircumferenceInputTextField extends StatefulWidget {
  const _WaistCircumferenceInputTextField({
    super.key,
  });

  @override
  State<_WaistCircumferenceInputTextField> createState() =>
      _WaistCircumferenceInputTextFieldState();
}

class _WaistCircumferenceInputTextFieldState
    extends State<_WaistCircumferenceInputTextField> {
  final TextEditingController _controller = TextEditingController();
  late BmiInputBloc _bmiInputBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return BmiInputTextField(
      hintText: "0.0",
      suffixText: "cm",
      controller: _controller,
      onChanged: (value) {
        if (value.trim().isNotEmpty) {
          _bmiInputBloc.waist = double.tryParse(value) ?? 0;
        } else {
          _bmiInputBloc.waist = 0;
        }
      },
    );
  }
}
