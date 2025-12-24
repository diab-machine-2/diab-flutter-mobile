import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart';

class BmiDateFilterBar extends StatefulWidget {
  const BmiDateFilterBar({super.key, this.onChanged});

  final void Function(BmiDateFilterType filterType)? onChanged;

  @override
  State<BmiDateFilterBar> createState() => _BmiDateFilterBarState();
}

class _BmiDateFilterBarState extends State<BmiDateFilterBar> {
  late BmiBloc _bmiBloc;

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final currentPeriodType = _bmiBloc.periodType;

    // Build labels like "7 day(s)" etc. to match existing text
    final labels = BmiDateFilterType.values
        .map((e) => "${e.days} ${R.string.day.tr()}")
        .toList();

    // Values are just indices; HorizontalSelector uses the index in the callback
    final values =
        List<int>.generate(BmiDateFilterType.values.length, (index) => index);

    final selectedIndex = currentPeriodType.index;

    return HorizontalSelector(
      onSelected: (index) {
        final filterType = BmiDateFilterType.values[index];
        widget.onChanged?.call(filterType);
      },
      initialValue: selectedIndex,
      values: values,
      labels: labels,
      height: 42,
      fontSize: 14,
    );
  }
}
