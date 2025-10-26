import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_date_picker.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/bmi_input_range_chart.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/bmi_input_text_field.dart';

class AddBmiWeightInputSession extends StatelessWidget {
  const AddBmiWeightInputSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          const AddBmiDatePicker(),
          const _WeightInputTextField(),
          const SizedBox(
            height: 12,
          ),
          const BmiInputRangeChart(),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _WeightInputTextField extends StatefulWidget {
  const _WeightInputTextField({
    super.key,
  });

  @override
  State<_WeightInputTextField> createState() => _WeightInputTextFieldState();
}

class _WeightInputTextFieldState extends State<_WeightInputTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late BmiInputBloc _bmiInputBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (_bmiInputBloc.weight != 0) {
        _controller.text = _bmiInputBloc.weight.toString();
      }
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BmiInputTextField(
      hintText: "0.00",
      suffixText: "kg",
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (value) {
        _bmiInputBloc.weight = double.tryParse(value) ?? 0;
      },
    );
  }
}
