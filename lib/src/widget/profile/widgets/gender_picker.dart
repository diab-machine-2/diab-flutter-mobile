import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/res/R.dart';

class GenderPicker extends StatefulWidget {
  final FixedExtentScrollController? controller;
  const GenderPicker({this.controller});

  @override
  _GenderPickerState createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  int selectedItem = 0;
  @override
  void initState() {
    super.initState();
    selectedItem = widget.controller!.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
        scrollController: widget.controller,
        selectionOverlay: null,
        onSelectedItemChanged: (value) {
          setState(() {
            selectedItem = value;
          });
        },
        itemExtent: 47.0,
        children: List<int>.generate(3, (i) => i)
            .map((e) => Center(
                  child: Text(e == 0 ? R.string.nam.tr() : e == 1 ? R.string.nu.tr() : R.string.other.tr(),
                      style: TextStyle(
                          color: selectedItem == e
                              ? R.color.mainColor
                              : R.color.color0xffC0C2C5,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
            .toList());
  }
}
