import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/utils.dart';

class DropdownColumnWidget extends StatefulWidget {
  final List<String?> listData;
  final String currentValue;
  final ValueChanged<String?> selectedValue;
  final String label;
  final Color color;
  final String hintText;

  const DropdownColumnWidget(
      {Key? key,
      required this.listData,
      required this.currentValue,
      required this.selectedValue,
      required this.label,
      required this.color,
      required this.hintText})
      : super(key: key);

  @override
  _DropdownColumnWidgetState createState() => _DropdownColumnWidgetState();
}

class _DropdownColumnWidgetState extends State<DropdownColumnWidget> {
  int? _selectedPos;
  List<String?>? list;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    final String firstElement = widget.hintText;
    if (Utils.isEmpty(widget.listData)) {
      try {
        if (list!.last != widget.listData.last) _selectedPos = null;
      } catch (e) {
        Console.log('DropdownColumnWidget Error', e.toString());
      }
      list = widget.listData;
      if (list!.contains(firstElement)) {
        if (_selectedPos == null)
          _selectedPos = list!.indexOf(widget.currentValue);
        return;
      }
      list!.insert(0, firstElement);

      if (_selectedPos == null)
        _selectedPos = list!.indexOf(widget.currentValue);
      if (_selectedPos! < 0) {
        _selectedPos = 0;
      }
      if (Utils.isEmpty(list) && widget.selectedValue != null) {
        final String? selectedValue =
            _selectedPos == 0 ? null : list![_selectedPos!];
        widget.selectedValue(selectedValue);
      }
    } else {
      list = [firstElement];
    }
  }

  @override
  Widget build(BuildContext context) {
    initData();
    final int sizeList = list!.length;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: R.color.gray, width: 1)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
              visible: Utils.isEmpty(widget.label),
              child: Text(
                widget.label,
                textAlign: TextAlign.start,
                style: TextStyle(color: widget.color, fontSize: 30),
              )),
          Visibility(
              visible: Utils.isEmpty(widget.label),
              child: const SizedBox(height: 5)),
          if (sizeList == 0)
            const Text('No data')
          else
            sizeList == 1
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(list![0] ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              color: R.color.gray,
                            )),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: R.color.gray,
                      )
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                      ),
                      hint: Text(
                        widget.hintText,
                        style: TextStyle(fontSize: 14, color: R.color.gray),
                      ),
                      value: _selectedPos != null && _selectedPos! >= 0
                          ? list![_selectedPos!]
                          : list![0],
                      items: list!
                          .map((item) => DropdownMenuItem<String>(
                                child: Text(
                                  item ?? "",
                                  style: TextStyle(
                                      fontSize: 14, color: widget.color),
                                ),
                                value: item,
                              ))
                          .toList(),
                      onChanged: widget.selectedValue == null
                          ? null
                          : (value) {
                              print(value);
                              setState(() {
                                _selectedPos = list!.indexOf(value);
                              });
                              final String? selectedValue = _selectedPos == 0
                                  ? null
                                  : list![_selectedPos!];
                              widget.selectedValue(selectedValue);
                            },
                    ),
                  ),
        ],
      ),
    );
  }
}
