import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/widget/create_food_dialog.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

typedef FoodCallback = Function(List<FoodModel>);

class FoodChoosen extends StatefulWidget {
  final List<FoodModel>? foods;
  final FoodCallback? callback;
  final String? title;
  FoodChoosen({this.foods, this.callback, this.title});
  @override
  _FoodChoosenState createState() => _FoodChoosenState();
}

class _FoodChoosenState extends State<FoodChoosen> with Observer {
  List<FoodModel> foods = [];
  double totalKcal = 0;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    foods = [...(widget.foods ?? [])];
    calculatorCalo();
    Observable.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(FoodChoosen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent rebuilds with a new foods list (e.g. after _toggleFood in SearchFood),
    // sync our internal list so the bottom panel stays consistent with the checkboxes.
    if (widget.foods != oldWidget.foods) {
      setState(() {
        foods = [...(widget.foods ?? [])];
        calculatorCalo();
      });
    }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName != 'add_food_to_cart' && notifyName != 'remove_food_from_cart') return;
    final FoodModel? foodModel = map?['food'];
    if (foodModel == null) return;
    if (notifyName == 'add_food_to_cart') {
      setState(() {
        this.foods.removeWhere((element) => foodModel.id == element.id);
        this.foods.add(foodModel);
        calculatorCalo();
      });
    }
    if (notifyName == 'remove_food_from_cart') {
      setState(() {
        this.foods.removeWhere((element) => foodModel.id == element.id);
        calculatorCalo();
        if (this.foods.isEmpty) {
          showAll = false;
        }
      });
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  calculatorCalo() {
    totalKcal = 0;
    foods.forEach((element) {
      final double calorie = (element.calorie ?? 0).toDouble();
      final double quantity = (element.quantity ?? 0).toDouble();
      final double portion = (element.portion ?? 0).toDouble();
      totalKcal += calorie * portion;
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
                          Text('${foods.length} ${R.string.mon_an.tr()}',
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
                              Text(R.string.kcal.tr(),
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
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: NetWorkImageWidget(
                                      imageUrl: foods[index].image?.url ?? '',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(foods[index].name ?? '',
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            foods[index].code ==
                                                    'OtherUneditable'
                                                ? '${R.string.da_an.tr()} ${((foods[index].quantity ?? 0) * (foods[index].calorie ?? 0)).round()} kcal'
                                                : '${R.string.da_an.tr()} ${roundAsFixed((foods[index].portion ?? 0) * (foods[index].quantity ?? 0))} ${foods[index].unit ?? ''}, ${((foods[index].portion ?? 0) * (foods[index].calorie ?? 0)).round()} kcal',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Observable.instance.notifyObservers([],
                                          notifyName: "remove_food_from_cart",
                                          map: {"food": foods[index]});
                                      setState(() {
                                        foods.removeAt(index);
                                        showAll = foods.length != 0;
                                        calculatorCalo();
                                      });
                                    },
                                    child: Image.asset(
                                      R.drawable.ic_trash_red,
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                ]));
                          },
                        ),
                      ),
                // Hai nút: Tạo món mới và Tiếp tục
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Button: Tạo món mới
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await CreateFoodDialog.show(
                              context: context,
                            );

                            if (result != null) {
                              setState(() {
                                foods.add(result);
                                calculatorCalo();
                              });
                              // Notify observers
                              Observable.instance.notifyObservers([],
                                  notifyName: "add_food_to_cart",
                                  map: {"food": result});
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: R.color.greenGradientBottom,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Tạo món mới',
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Button: Tiếp tục
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (foods.isEmpty) return;
                            if (widget.callback != null) {
                              widget.callback!(foods);
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: foods.isEmpty ? R.color.color0xffE5E5E5 : R.color.mainColor,
                              borderRadius: BorderRadius.circular(100),
                              gradient: foods.isEmpty ? null : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  R.color.greenGradientTop,
                                  R.color.greenGradientBottom,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.title ?? R.string.tiep_tuc.tr(),
                                style: TextStyle(
                                  color: foods.isEmpty ? R.color.color0xff636A6B : R.color.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    ]);
  }
}
