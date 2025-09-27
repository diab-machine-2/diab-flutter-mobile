import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

typedef WeightCallback = Function(double);

class CustomWeightPicker extends StatefulWidget {
  final WeightCallback callback;
  final String title;
  final String? subTitle;
  final int max;
  final num numberDefault;
  final String unit;

  CustomWeightPicker(
      {required this.callback,
      required this.title,
      this.subTitle,
      required this.max,
      required this.numberDefault,
      required this.unit});

  @override
  CustomWeightPickerState createState() => CustomWeightPickerState();
}

class CustomWeightPickerState extends State<CustomWeightPicker> {
  late FixedExtentScrollController numController;
  late FixedExtentScrollController num2Controller;
  late int selectedNum;
  late int selectedNum2;

  @override
  void initState() {
    selectedNum = widget.numberDefault.floor();
    selectedNum2 =
        ((widget.numberDefault - widget.numberDefault.floor()) * 10).toInt();
    super.initState();
    numController = FixedExtentScrollController(initialItem: selectedNum);
    num2Controller =
        FixedExtentScrollController(initialItem: selectedNum2 == 0 ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
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
                                        child: Text(widget.subTitle ?? '',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      )
                              ]),
                        ),
                        IconButton(
                            // padding: EdgeInsets.only(right: 30),
                            icon: Icon(Icons.close, color: Colors.grey),
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
                              children:
                                  List<int>.generate(widget.max + 1, (i) => i)
                                      .map((e) => Center(
                                            child: Text('$e',
                                                style: TextStyle(
                                                    color: selectedNum == e
                                                        ? Color(0xff01645A)
                                                        : Color(0xffC0C2C5),
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))
                                      .toList())),
                      Text(',',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                          height: 150,
                          width: 106,
                          child: CupertinoPicker(
                              scrollController: num2Controller,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedNum2 = value == 0 ? 0 : 5;
                                });
                              },
                              itemExtent: 47.0,
                              children: List<int>.generate(2, (i) => i * 5)
                                  .map((e) => Center(
                                        child: Text('$e',
                                            style: TextStyle(
                                                color: selectedNum2 == e
                                                    ? Color(0xff01645A)
                                                    : Color(0xffC0C2C5),
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                  .toList())),
                      SizedBox(width: 8),
                      Text(widget.unit)
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
                              widget
                                  .callback(selectedNum + (selectedNum2 / 10));
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
                                        color: Colors.white,
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
