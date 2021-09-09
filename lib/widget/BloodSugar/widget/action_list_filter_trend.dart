import 'package:flutter/material.dart';
import 'package:medical/theme/app_theme.dart';

typedef TimeCallback = Function(String, int);

class ActionListFilterTrend extends StatefulWidget {
  final int selectedIndex;
  final TimeCallback callback;
  ActionListFilterTrend({this.selectedIndex, this.callback});
  @override
  _ActionListFilterTrendState createState() => _ActionListFilterTrendState();
}

class _ActionListFilterTrendState extends State<ActionListFilterTrend> {
  var data = [
    'Tất cả',
    'Trước ăn',
    'Sau ăn',
    'Trước tập',
    'Sau tập',
    'Nửa đêm'
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex != null) {
      selectedIndex = widget.selectedIndex - 1;
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
            decoration: BoxDecoration(color: Color(0xffE5E5E5)),
          ),
        ),
        SizedBox(height: 27),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chọn khung giờ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset('assets/images/x_icon.png'),
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
              return _buildItem(data[index], index);
            }),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () {
              widget.callback(data[selectedIndex], selectedIndex);
              Navigator.pop(context);
            },
            child: SafeArea(
              child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  height: 48,
                  width: 195,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [greenGradientTop, greenGradientBottom]),
                      borderRadius: BorderRadius.circular(200)),
                  child: Center(
                    child: Text('Lưu',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  )),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildItem(String title, int index) {
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
              color: selectedIndex == index ? greenbg : Colors.white,
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
                              ? Text(title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400))
                              : Text(title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: mainColor)),
                          selectedIndex == index
                              ? Image.asset('assets/images/check_mark.png',
                                  width: 24, height: 24)
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  //index != times.length - 1
                  1 == 1
                      ? Container(
                          height: 1,
                          width: 373,
                          color: selectedIndex == index
                              ? greenbg
                              : Color(0xffD6D8E0))
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
