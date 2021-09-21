import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/logger.dart';
import 'package:medical/src/utils/utils.dart';

class DropdownColumnWidget extends StatefulWidget {
  final List<String> listData;
  final String currentValue;
  final ValueChanged<String> selectedValue;
  final String label;
  final Color color;
  final String hintText;

  const DropdownColumnWidget(
      {Key key,
      @required this.listData,
      @required this.currentValue,
      @required this.selectedValue,
      @required this.label,
      @required this.color,
      @required this.hintText})
      : super(key: key);

  @override
  _DropdownColumnWidgetState createState() => _DropdownColumnWidgetState();
}

class _DropdownColumnWidgetState extends State<DropdownColumnWidget> {
  int _selectedPos;
  List<String> list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData() {
    String firstElement = widget.hintText ?? "Chọn";
    if (Utils.isEmpty(widget.listData)) {
      try {
        if (list.last != widget.listData.last) _selectedPos = null;
      } catch (e) {
        logger.e(e.toString());
      }
      list = widget.listData;
      if (list.contains(firstElement)) {
        if (_selectedPos == null)
          _selectedPos = list.indexOf(widget.currentValue);
        return;
      }
      list.insert(0, firstElement);

      if (_selectedPos == null)
        _selectedPos = list.indexOf(widget.currentValue) ?? 0;
      if (_selectedPos < 0) {
        _selectedPos = 0;
      }
      if (Utils.isEmpty(list) && widget.selectedValue != null) {
        String selectedValue = _selectedPos == 0 ? null : list[_selectedPos];
        widget.selectedValue(selectedValue);
      }
    } else {
      list = []..add(firstElement);
    }
  }

  @override
  Widget build(BuildContext context) {
    initData();
    int sizeList = list.length ?? 0;

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
                  widget.label ?? "",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: widget.color ?? R.color.gray, fontSize: 30.sp),
                )),
            Visibility(
                visible: Utils.isEmpty(widget.label),
                child: SizedBox(
                  height: 5,
                )),
            sizeList == 0
                ? Text("No data")
                : (sizeList == 1
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(list[0] ?? "",
                                style: TextStyle(
                                  fontSize: 14.sp,
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
//                            isDense: true,
                            isExpanded: true,
                            style: TextStyle(
                              color: widget.color ?? R.color.gray,
                              fontSize: 14.sp,
                            ),
                            hint: Text(
                              widget.hintText ?? "",
                              style: TextStyle(
                                  fontSize: 14.sp, color: R.color.gray),
                            ),
                            value: _selectedPos != null && _selectedPos >= 0
                                ? list[_selectedPos]
                                : list[0],
                            items: list
                                .map((item) => DropdownMenuItem<String>(
                                      child: Text(
                                        item ?? "",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color:
                                                widget.color ?? R.color.gray),
                                      ),
                                      value: item,
                                    ))
                                .toList(),
                            onChanged: widget.selectedValue == null
                                ? null
                                : (value) {
                                    print(value);
                                    setState(() {
                                      _selectedPos = list.indexOf(value);
                                    });
                                    String selectedValue = _selectedPos == 0
                                        ? null
                                        : list[_selectedPos];
                                    widget.selectedValue(selectedValue);
                                  }),
                      )),
            //SizedBox(height: 10)
          ],
        ));
  }
}
