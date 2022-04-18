import 'package:flutter/cupertino.dart';

class BirthDayPicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onChanged;
  const BirthDayPicker({this.selectedDate, this.onChanged});
  @override
  _BirthDayPickerState createState() => _BirthDayPickerState();
}

class _BirthDayPickerState extends State<BirthDayPicker> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
        initialDateTime: selectedDate,
        maximumYear: DateTime.now().year,
        minimumYear: 1900,
        mode: CupertinoDatePickerMode.date,
        onDateTimeChanged: (value) {
          widget.onChanged!(value);
          setState(() {
            selectedDate = value;
          });
        });
  }
}
