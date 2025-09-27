import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BmiHeightPicker extends StatefulWidget {
  const BmiHeightPicker({
    super.key,
    this.onChanged,
  });

  final void Function(int height)? onChanged;

  @override
  State<BmiHeightPicker> createState() => _BmiHeightPickerState();
}

class _BmiHeightPickerState extends State<BmiHeightPicker> {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final numbers = List<int>.generate(200 - 100 + 1, (i) => 100 + i);
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: numbers.length ~/ 2);
    widget.onChanged?.call(numbers[numbers.length ~/ 2]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
        itemExtent: 48.0,
        onSelectedItemChanged: (int index) {
          selectedIndex.value = index;
          widget.onChanged?.call(numbers[index]);
        },
        scrollController: _scrollController,
        children: numbers
            .map((e) => Center(
                  child: Text(
                    "$e",
                    style:
                        R.style.alertTitle.copyWith(color: R.color.mainColor),
                  ),
                ))
            .toList());
  }
}
