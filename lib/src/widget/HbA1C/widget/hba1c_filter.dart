import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';

typedef TimeCallback = Function(String, int);

class FillterHbA1C extends StatefulWidget {
  final selectedIndex;
  final TimeCallback callback;
  FillterHbA1C({
    Key key,
    this.selectedIndex,
    this.callback,
  }) : super(key: key);
  @override
  _FillterHbA1CState createState() => _FillterHbA1CState();
}

class _FillterHbA1CState extends State<FillterHbA1C> {
  var data = ['6 tháng', '1 năm', '2 năm'];

  int selectedIndex = 0;
  String time = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
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
              Text('Lọc theo thời gian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset(R.drawable.x_icon),
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
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final name = data[index];
              return _buildItem(context, index, name);
            }),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () {
              widget.callback(data[selectedIndex], selectedIndex);
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
                  child: Text('Lưu',
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
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
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          selectedIndex != index
                              ? Text(name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400))
                              : Text(name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: R.color.mainColor)),
                          selectedIndex == index
                              ? Image.asset(R.drawable.ic_check_mark,
                                  width: 24, height: 24)
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  index != data.length - 1
                      ? Container(
                          height: 1,
                          width: 373,
                          color: selectedIndex == index
                              ? R.color.greenbg
                              : R.color.color0xffD6D8E0)
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
