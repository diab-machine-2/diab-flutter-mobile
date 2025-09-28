import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

typedef NumCallback = Function(int?);

class CustomNumPicker extends StatefulWidget {
  final NumCallback? callback;
  final String? title;
  final String? subTitle;
  final int? max;
  final int? numberDefault;
  final String? unit;
  int? range;

  CustomNumPicker(
      {this.callback,
      this.title,
      this.subTitle,
      this.max,
      this.numberDefault,
      this.unit,
      this.range = 1});

  @override
  CustomNumPickerState createState() => CustomNumPickerState();
}

class CustomNumPickerState extends State<CustomNumPicker> {
  FixedExtentScrollController? numController;
  int? selectedNum;
  List<int> list = [];

  @override
  void initState() {
    list.clear();
    for (int i = 0; i <= widget.max!; i = i + widget.range!) {
      list.add(i);
    }
    selectedNum = widget.numberDefault! ~/ widget.range!;
    super.initState();
    numController = FixedExtentScrollController(initialItem: selectedNum!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.title.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                widget.subTitle == null
                                    ? SizedBox()
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, right: 8),
                                        child: Text(widget.subTitle!,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      )
                              ]),
                        ),
                        IconButton(
                            // padding: EdgeInsets.only(right: 30),
                            icon: Icon(Icons.close, color: R.color.grey),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 150,
                          width: 106,
                          child: CupertinoPicker(
                              scrollController: numController,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedNum = value;
                                });
                              },
                              itemExtent: 47.0,
                              children: list
                                  .map((e) => Center(
                                        child: Text('$e',
                                            style: TextStyle(
                                                color: selectedNum ==
                                                        (e / widget.range!)
                                                    ? R.color.mainColor
                                                    : R.color.color0xffC0C2C5,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                  .toList())),
                      SizedBox(width: 8),
                      Text(widget.unit!)
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: R.color.grayBorder),
                                child: Center(
                                  child: Text(R.string.cancel.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.callback!(selectedNum! * widget.range!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43,
                              width: 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ]),
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Center(
                                child: Text(R.string.tiep_tuc.tr(),
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
