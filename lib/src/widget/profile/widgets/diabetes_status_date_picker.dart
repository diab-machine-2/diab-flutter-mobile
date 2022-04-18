import 'package:flutter/cupertino.dart';
import 'package:medical/res/R.dart';

class DiabetesStatusDatePicker extends StatefulWidget {
  final int? year;
  final Function(int)? onChanged;
  const DiabetesStatusDatePicker({this.year, this.onChanged});

  @override
  _DiabetesStatusDatePickerState createState() =>
      _DiabetesStatusDatePickerState();
}

class _DiabetesStatusDatePickerState extends State<DiabetesStatusDatePicker> {
  FixedExtentScrollController? scrollController;
  int selectedYear = 0;
  @override
  void initState() {
    super.initState();
    scrollController =
        FixedExtentScrollController(initialItem: widget.year! - 1900);
    selectedYear = widget.year! - 1900;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
        scrollController: scrollController,
        selectionOverlay: null,
        onSelectedItemChanged: (value) {
          widget.onChanged!(value + 1900);
          setState(() {
            selectedYear = value;
          });
        },
        itemExtent: 47.0,
        children: List<int>.generate(DateTime.now().year + 1 - 1900, (i) => i)
            .map((e) => Center(
                  child: Text((e + 1900).toString(),
                      style: TextStyle(
                          color: selectedYear == e
                              ? R.color.mainColor
                              : R.color.color0xffC0C2C5,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
            .toList());
  }
}
