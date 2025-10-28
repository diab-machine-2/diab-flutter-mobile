import 'package:flutter/cupertino.dart';
import 'package:medical/res/R.dart';

class BmiHeightPicker extends StatefulWidget {
  const BmiHeightPicker({
    super.key,
    this.onChanged,
    this.initialValue,
  });

  final void Function(int height)? onChanged;
  final int? initialValue;

  @override
  State<BmiHeightPicker> createState() => _BmiHeightPickerState();
}

class _BmiHeightPickerState extends State<BmiHeightPicker> {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final numbers = List<int>.generate(200 - 100 + 1, (i) => 100 + i);
  late FixedExtentScrollController _scrollController;
  late int initialIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      initialIndex = numbers.indexOf(widget.initialValue!);
    } else {
      initialIndex = numbers.length ~/ 2;
    }
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex,
    );
    widget.onChanged?.call(widget.initialValue ?? numbers[initialIndex]);
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
