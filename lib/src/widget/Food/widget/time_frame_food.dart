import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/theme/app_theme.dart';

typedef TimeCallback = Function(TimeFrameModel);

class FoodTimeFrame extends StatefulWidget {
  final TimeFrameModel selected;
  final TimeCallback callback;
  FoodTimeFrame({@required this.selected, this.callback});
  @override
  _FoodTimeFrameState createState() => _FoodTimeFrameState();
}

class _FoodTimeFrameState extends State<FoodTimeFrame> {
  TimeFrameModel selected;

  List<TimeFrameModel> times = [];

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    times = await FoodClient().fetchFoodTimeFrame();
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        54;

    final double countHight = times.length * 48.0 + 216;
    return SafeArea(
        child: Container(
      height: countHight > height ? height : countHight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
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
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
          Expanded(
            child: ListView.builder(
                physics: countHight > height
                    ? AlwaysScrollableScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 8, top: 10),
                itemCount: times.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(times[index]);
                }),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  widget.callback(selected);
                  Navigator.pop(context);
                },
                child: Container(
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
                              color: R.color.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    )),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildItem(TimeFrameModel model) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selected = model;
              });
            },
            child: Container(
              color: (selected != null && selected.id == model.id)
                  ? greenbg
                  : R.color.white,
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
                          selected != null && selected.id == model.id
                              ? Text(model.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: mainColor))
                              : Text(model.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                          selected != null && selected.id == model.id
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
                          color: selected != null && selected.id == model.id
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
