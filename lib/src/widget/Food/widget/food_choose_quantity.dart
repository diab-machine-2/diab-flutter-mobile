import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/helper/show_message.dart';

typedef FoodQuantityCallback = Function(FoodModel);

class FoodChooseQuantity extends StatefulWidget {
  final FoodModel? model;
  final FoodModel? selectedModel;
  final String? categoryId;
  final FoodQuantityCallback? callback;
  FoodChooseQuantity(
      {this.model, this.selectedModel, this.categoryId, this.callback});
  @override
  _FoodChooseQuantityState createState() => _FoodChooseQuantityState();
}

class _FoodChooseQuantityState extends State<FoodChooseQuantity> {
  DateTime selectedDate = DateTime.now();

  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int selectedQuantity = 1;
  int selectedPercent = 0;
  bool? isLike = false;

  @override
  void initState() {
    super.initState();
    isLike = widget.model!.liked;
    if (widget.selectedModel != null) {
      selectedQuantity = widget.selectedModel!.quantity.floor();
      selectedPercent =
          ((widget.selectedModel!.quantity - selectedQuantity) * 10).round();
      //selectedPercent = selectedPercent == 0 ? 0 : (selectedPercent + 1);
    }
    hourController = FixedExtentScrollController(initialItem: selectedQuantity);
    minuteController =
        FixedExtentScrollController(initialItem: selectedPercent);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (widget.model!.calorie != null) {
      items.add(buildItem(R.string.calo.tr(), widget.model!.calorie, R.string.kcal.tr()));
    }
    if (widget.model!.lipid != null) {
      items.add(buildItem(R.string.beo.tr(), widget.model!.lipid, 'g'));
    }
    if (widget.model!.glucose != null) {
      items.add(buildItem(R.string.duong.tr(), widget.model!.glucose, 'g'));
    }
    if (widget.model!.protein != null) {
      items.add(buildItem(R.string.dam.tr(), widget.model!.protein, 'g'));
    }
    if (widget.model!.fibre != null) {
      items.add(buildItem(R.string.xo.tr(), widget.model!.fibre, 'g'));
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  R.color.color0xffB1DDDB.withAlpha(90),
                                  R.color.color0xFFFED31B.withAlpha(90),
                                ],
                                begin: FractionalOffset(0.3, -0.5),
                                end: FractionalOffset(0, 1),
                                stops: [0.0, 1.0])),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(Icons.arrow_back)),
                                      SizedBox(width: 12),
                                      Text(widget.model!.name!,
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isLike = !isLike!;
                                      });
                                      likeFood();
                                    },
                                    child: Container(
                                        color: R.color.transparent,
                                        child: !isLike!
                                            ? Image.asset(
                                                R.drawable.ic_heart_line,
                                                width: 24,
                                                height: 24)
                                            : Image.asset(
                                                R.drawable.ic_heart_fill,
                                                width: 24,
                                                height: 24)),
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(widget.model!.description ?? '',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                              SizedBox(height: 12),
                              Text(
                                  '${R.string.khau_phan.tr()} ${widget.model!.portion.round()} ${widget.model!.unit} ${R.string.bao_gom.tr()}:',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                              SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: items)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(R.string.khau_phan_cua_ban.tr(),
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 150,
                              width: 106,
                              child: CupertinoPicker(
                                  scrollController: hourController,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (value) {
                                    setState(() {
                                      selectedQuantity = value;
                                      //widget.callback(selectedHour, selectedMinute);
                                    });
                                  },
                                  itemExtent: 47.0,
                                  children: List<int>.generate(16, (i) => i)
                                      .map((e) => Center(
                                            child: Text((e).toString(),
                                                style: TextStyle(
                                                    color: selectedQuantity == e
                                                        ? R.color.mainColor
                                                        : R.color.color0xffC0C2C5,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))
                                      .toList())),
                          SizedBox(width: 8),
                          Text(',',
                              style: TextStyle(
                                  color: R.color.mainColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Container(
                              height: 150,
                              width: 106,
                              child: CupertinoPicker(
                                  scrollController: minuteController,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (value) {
                                    setState(() {
                                      selectedPercent = value;
                                      //widget.callback(selectedHour, selectedMinute);
                                    });
                                  },
                                  itemExtent: 47.0,
                                  children: List<int>.generate(10, (i) => i)
                                      .map((e) => Center(
                                            child: Text('$e',
                                                style: TextStyle(
                                                    color: selectedPercent == e
                                                        ? R.color.mainColor
                                                        : R.color.color0xffC0C2C5,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))
                                      .toList()))
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(children: [
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                decoration: BoxDecoration(
                                    color: R.color.grayBorder,
                                    borderRadius: BorderRadius.circular(21.5)),
                                child: Center(
                                    child: Text(R.string.cancel.tr(),
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)))),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final double quantity =
                                  selectedQuantity + (selectedPercent / 10);
                              if (quantity == 0) {
                                Message.showToastMessage(
                                    context, R.string.ban_chua_nhap_du_lieu.tr());
                                return;
                              }
                              Observable.instance.notifyObservers([],
                                  notifyName: "add_food_to_cart",
                                  map: {
                                    "food": FoodModel(
                                        id: widget.model!.id,
                                        name: widget.model!.name,
                                        portion: widget.model!.portion,
                                        unit: widget.model!.unit,
                                        calorie: widget.model!.calorie,
                                        glucose: widget.model!.glucose,
                                        lipid: widget.model!.lipid,
                                        protein: widget.model!.protein,
                                        fibre: widget.model!.fibre,
                                        image: widget.model!.image,
                                        liked: widget.model!.liked,
                                        text: widget.model!.text,
                                        description: widget.model!.description,
                                        foodCategoryId:
                                            widget.model!.foodCategoryId,
                                        quantity: quantity)
                                  });
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                decoration: BoxDecoration(
                                    color: R.color.mainColor,
                                    borderRadius: BorderRadius.circular(21.5),
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          R.color.greenGradientTop,
                                          R.color.greenGradientBottom
                                        ])),
                                child: Center(
                                    child: Text(R.string.yes.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)))),
                          ),
                        ),
                        SizedBox(width: 16),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildItem(String title, double? number, String unit) {
    return Container(
        child: Column(
      children: [
        Text(title, style: TextStyle(color: R.color.primaryGreyColor)),
        SizedBox(height: 4),
        Text('$number $unit',
            style: TextStyle(color: R.color.mainColor, fontWeight: FontWeight.w600))
      ],
    ));
  }

  likeFood() async {
    BotToast.showLoading();
    try {
      if (isLike!) {
        await FoodClient().addFoodToFavorite(widget.model!.id);
        Observable.instance.notifyObservers([], notifyName : "add_food_to_favorite");
        // DartNotificationCenter.post(channel: 'add_food_to_favorite');
      } else {
        await FoodClient().romoveFoodFromFavorite(widget.model!.id);
        Observable.instance.notifyObservers([], notifyName : "add_food_to_favorite");
        // DartNotificationCenter.post(channel: 'add_food_to_favorite');
      }

      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
