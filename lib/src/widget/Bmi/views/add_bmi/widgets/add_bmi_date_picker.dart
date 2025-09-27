import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view_old/widgets/custom_datetime_picker.dart';
import 'package:medical/src/widget/helper/helper.dart';

class AddBmiDatePicker extends StatefulWidget {
  const AddBmiDatePicker({
    super.key,
  });

  @override
  State<AddBmiDatePicker> createState() => _AddBmiDatePickerState();
}

class _AddBmiDatePickerState extends State<AddBmiDatePicker> {
  late BmiInputBloc _bmiInputBloc;

  final DateFormat _dateFormat = DateFormat(Const.DATE_FORMAT_POST);

  @override
  void initState() {
    _bmiInputBloc = context.read();
    if (_bmiInputBloc.currentInputTime == null) {
      _bmiInputBloc.currentInputTime = DateTime.now();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiInputBloc, BmiInputState>(
        buildWhen: (_, state) =>
            state is BmiInputDataChangedState &&
            state.event == BmiInputDataChangeEvent.inputTimeChanged,
        builder: (context, state) {
          return Center(
            child: InkWell(
              onTap: _onTapDateTime,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: R.color.color0xffE5E5E5),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dateFormat.format(
                            _bmiInputBloc.currentInputTime ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: R.color.textDark,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _onTapDateTime() async {
    // await TrackingManager.analytics
    //     .logEvent(name: 'component_clicked', parameters: {
    //   "screen_name": 'kpi_glycemic_add',
    //   'component_name': 'date_picker_glycemic',
    // });

    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => DateMultiPicker(
        initDate: _bmiInputBloc.currentInputTime,
        callback: (date) {
          _bmiInputBloc.currentInputTime = date;
        },
      ),
    );
  }
}
