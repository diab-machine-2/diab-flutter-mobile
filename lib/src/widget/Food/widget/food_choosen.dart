import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/helper/helper.dart';

typedef FoodCallback = Function(List<FoodModel>);

class FoodChoosen extends StatefulWidget {
  final List<FoodModel> foods;
  final FoodCallback callback;
  FoodChoosen({this.foods, this.callback});
  @override
  _FoodChoosenState createState() => _FoodChoosenState();
}

class _FoodChoosenState extends State<FoodChoosen> {
  List<FoodModel> foods = [];
  double totalKcal = 0;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    foods = [...widget.foods];
    calculatorCalo();
    DartNotificationCenter.subscribe(
        channel: 'add_food_to_cart',
        observer: this,
        onNotification: (data) {
          if (data is FoodModel) {
            setState(() {
              this.foods.removeWhere((element) => data.id == element.id);
              this.foods.add(data);
              calculatorCalo();
            });
          }
        });
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'add_food_to_cart', observer: this);
    super.dispose();
  }

  calculatorCalo() {
    totalKcal = 0;
    foods.forEach((element) {
      totalKcal += element.calorie * element.quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);

    final double itemHeight = (showAll ? (foods.length * 72.0) : 0.0); //''+
    // (MediaQuery.of(context).padding.top +
    //     //MediaQuery.of(context).padding.bottom +
    //     56 +
    //     0 +
    //     39);

    final double height = itemHeight > maxHeight ? maxHeight : itemHeight;
    return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
      !showAll
          ? SizedBox()
          : GestureDetector(
              onTap: () {
                setState(() {
                  setState(() {
                    showAll = !showAll;
                  });
                });
              },
              child: Container(color: R.color.black.withOpacity(0.5))),
      Container(
          // height: height,
          decoration: BoxDecoration(
              color: R.color.white,
              border: Border.all(color: R.color.color0xffE5E5E5, width: 2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16))),
          padding: EdgeInsets.only(bottom: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (foods.length == 0) {
                      return;
                    }
                    setState(() {
                      showAll = !showAll;
                    });
                  },
                  child: Container(
                    color: R.color.transparent,
                    margin: EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${foods.length} món ăn',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          Row(
                            children: [
                              Text('${totalKcal.round()} ',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              Text('kcal',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontWeight: FontWeight.w400)),
                              Icon(showAll
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up)
                            ],
                          )
                        ]),
                  ),
                ),
                !showAll
                    ? SizedBox()
                    : SizedBox(
                        height: height,
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemCount: foods.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                                height: 1, color: R.color.color0xfff5f5f5);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 11, bottom: 11),
                                child: Row(children: [
                                  Image.network(foods[index].image.url ?? '',
                                      width: 50, height: 50),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(foods[index].name,
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            'Đã ăn ${roundAsFixed(foods[index].portion * foods[index].quantity)} ${foods[index].unit}, ${formatNumber(foods[index].quantity * foods[index].calorie)} kcal',
                                            style: TextStyle(
                                                color: R.color.color0xff172823,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      DartNotificationCenter.post(
                                          channel: 'remove_food_from_cart',
                                          options: foods[index]);
                                      setState(() {
                                        foods.removeAt(index);
                                        showAll = foods.length != 0;
                                        calculatorCalo();
                                      });
                                    },
                                    child: Image.asset(
                                      'assets/images/trash.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                ]));
                          },
                        ),
                      ),
                GestureDetector(
                  onTap: () {
                    widget.callback(foods);
                  },
                  child: Container(
                      height: 48,
                      width: 195,
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                      child: Center(
                          child: Text('Lưu',
                              style: TextStyle(
                                  color: R.color.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)))),
                ),
              ],
            ),
          )),
    ]);
  }
}
