import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/show_message.dart';

typedef TimeCallback = Function(int, List<int>);

class PopupReminder extends StatefulWidget {
  final selectedIndex;
  final List<int> selectedItems;
  final TimeCallback callback;
  PopupReminder({
    Key? key,
    this.selectedIndex,
    required this.selectedItems,
    required this.callback,
  }) : super(key: key);
  @override
  _PopupReminderState createState() => _PopupReminderState();
}

class _PopupReminderState extends State<PopupReminder> {
  final data = [R.string.every_day_except_sunday.tr(), 'Hàng tuần'];
  final weeks = [
    R.string.day_in_week_monday.tr(),
    R.string.day_in_week_tuesday.tr(),
    R.string.day_in_week_wednesday.tr(),
    R.string.day_in_week_thursday.tr(),
    R.string.day_in_week_friday.tr(),
    R.string.day_in_week_saturday.tr(),
    R.string.day_in_week_sunday.tr()
  ];

  int selectedIndex = 0;
  List<int> selectedItems = [];
  String time = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    selectedItems = widget.selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(children: [
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
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chọn thời gian lặp lại',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 24,
                        width: 24,
                        child: Image.asset(R.drawable.ic_x),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 1, width: 373, color: Color(0xffD6D8E0));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final name = data[index];
                      return _buildItem(context, index, name);
                    }),
              ),
              SizedBox(height: 8),
            ]),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if (selectedIndex == 1 && selectedItems.length == 0) {
                  Message.showToastMessage(context, 'Bạn chưa chọn ngày');
                  return;
                }
                widget.callback(selectedIndex, selectedItems);
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
                    child: Text(R.string.save,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  )),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildItem(BuildContext context, int index, String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              color: selectedIndex == index ? R.color.greenbg : Colors.white,
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectedIndex != index
                      ? Text(name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400))
                      : Text(name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: R.color.mainColor)),
                  Image.asset(
                      selectedIndex == index
                          ? R.drawable.ic_radio_green
                          : R.drawable.ic_radio,
                      width: 24,
                      height: 24)
                ],
              )),
          selectedIndex == 1 && index == 1
              ? ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: weeks.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                        height: 0.5, width: 373, color: Color(0xffD6D8E0));
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedItems.contains(index + 1)
                              ? selectedItems.remove(index + 1)
                              : selectedItems.add(index + 1);
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 38, right: 10),
                          color: Colors.white,
                          height: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(weeks[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                              selectedItems.contains(index + 1)
                                  ? Image.asset(R.drawable.ic_check_mark,
                                      width: 24, height: 24)
                                  : SizedBox()
                            ],
                          )),
                    );
                  })
              : SizedBox()
        ],
      ),
    );
  }
}
