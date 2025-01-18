import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

typedef TimeCallback = Function(String, int?);

class FillterGlucosePanel extends StatefulWidget {
  final selectedIndex;
  final List<String>? data;
  final TimeCallback? callback;
  FillterGlucosePanel({
    Key? key,
    this.selectedIndex,
    this.data,
    this.callback,
  }) : super(key: key);
  @override
  _FillterGlucosePanelState createState() => _FillterGlucosePanelState();
}

class _FillterGlucosePanelState extends State<FillterGlucosePanel> {
  List<String>? data = [
    R.string.filter_day.tr(args: ['7']),
    R.string.filter_day.tr(args: ['14']),
    R.string.filter_day.tr(args: ['30']),
    R.string.filter_day.tr(args: ['90']),
  ];

  int? selectedIndex = 2;
  String time = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    if (widget.data != null) {
      data = widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24),
                Text(R.string.filter.tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 24,
                    width: 24,
                    child: Image.asset(R.drawable.ic_close),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
              itemCount: data!.length,
              itemBuilder: (BuildContext context, int index) {
                final name = data![index];
                return _buildItem(context, index, name);
              }),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                widget.callback!(data![selectedIndex!], selectedIndex);
                Navigator.pop(context);
              },
              child: Container(
                  height: 48,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: R.color.accentColor,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Center(
                    child: Text(R.string.confirm.tr(),
                        style: TextStyle(
                            color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, String name) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: R.color.color0xffF2F6F9,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (selectedIndex == index)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: R.color.accentColor,
                      width: 1,
                    ),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: R.color.accentColor,
                    ),
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: R.color.color0xffE5E5E5,
                      width: 1,
                    ),
                    color: Colors.white,
                  ),
                  child: selectedIndex == index 
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
                ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
                  color: selectedIndex == index ? R.color.mainColor : Colors.black,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class FillterBloodPanel extends StatefulWidget {
  final selectedIndex;
  final List<String>? data;
  final TimeCallback? callback;
  FillterBloodPanel({
    Key? key,
    this.selectedIndex,
    this.data,
    this.callback,
  }) : super(key: key);
  @override
  _FillterBloodPanelState createState() => _FillterBloodPanelState();
}

class _FillterBloodPanelState extends State<FillterBloodPanel> {
  List<String>? data = [
    R.string.filter_day.tr(args: ['7']),
    R.string.filter_day.tr(args: ['14']),
    R.string.filter_day.tr(args: ['30']),
    R.string.filter_day.tr(args: ['90']),
  ];

  int? selectedIndex = 2;
  String time = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    if (widget.data != null) {
      data = widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        Center(
          child: Container(
            height: 3.86,
            width: 60,
            decoration: BoxDecoration(color: R.color.color0xffE5E5E5),
          ),
        ),
        SizedBox(height: 27),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(R.string.chon_khung_gio.tr(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset(R.drawable.ic_close),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 8, top: 10),
            itemCount: data!.length,
            itemBuilder: (BuildContext context, int index) {
              final name = data![index];
              return _buildItem(context, index, name);
            }),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () {
              widget.callback!(data![selectedIndex!], selectedIndex);
              Navigator.pop(context);
            },
            child: Container(
                height: 48,
                width: 195,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [R.color.greenGradientTop, R.color.greenGradientBottom]),
                    borderRadius: BorderRadius.circular(200)),
                child: Center(
                  child: Text(R.string.save.tr(),
                      style: TextStyle(
                          color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                )),
          ),
        ),
      ],
    ));
  }

  Widget _buildItem(BuildContext context, int index, String name) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              color: selectedIndex == index ? R.color.greenbg : R.color.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          selectedIndex != index
                              ? Text(name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
                              : Text(name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: R.color.mainColor)),
                          selectedIndex == index
                              ? Image.asset(R.drawable.ic_check_mark, width: 24, height: 24)
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  index != data!.length - 1
                      ? Container(
                          height: 1,
                          width: 373,
                          color: selectedIndex == index ? R.color.greenbg : R.color.color0xffD6D8E0)
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
