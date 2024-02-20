import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';
import 'package:easy_localization/easy_localization.dart';

typedef FoodCallback = Function(String);

class FoodOfCategory extends StatefulWidget {
  final FoodSubCategoryModel? category;
  final List<FoodModel?>? foods;
  final FoodCallback? callback;
  final double? suggestKcal;
  FoodOfCategory({this.category, this.foods, this.callback, required this.suggestKcal});
  @override
  _FoodOfCategoryState createState() => _FoodOfCategoryState();
}

class _FoodOfCategoryState extends State<FoodOfCategory> {
  DateTime selectedDate = DateTime.now();
  List<FoodModel> foods = [];
  List<FoodModel?> selectedFoods = [];
  @override
  void initState() {
    super.initState();
    selectedFoods = [...widget.foods!];
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    final result =
        await FoodClient().fetchFoodCategory(widget.category!.id, null, null);
    foods = result.foods;
    BotToast.closeAllLoading();
    setState(() {});
  }

  double? getKcalLeft(FoodModel? selectedModel) {
    if (widget.suggestKcal == null) return null;
    double totalSelectedKcal = 0;
    for (final food in selectedFoods) {
      totalSelectedKcal += food?.totalKcal ?? 0;
    }
    final double kcalLeft = widget.suggestKcal! -
        totalSelectedKcal +
        (selectedModel?.totalKcal ?? 0);
    return max(kcalLeft, 0);
  }

  @override
  Widget build(BuildContext context) {
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
                child: Container(
                    height: MediaQuery.of(context).size.height * 3 / 4,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 8),
                                  child: Text(
                                      '${R.string.chon_mon.tr()} ${widget.category!.name}',
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemCount: foods.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            height: 1,
                                            color: R.color.color0xffE5E5E5);
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final selectedIndex = selectedFoods
                                            .lastIndexWhere((element) =>
                                                element!.id == foods[index].id);
                                        final FoodModel? selectedModel =
                                            selectedIndex != -1
                                                ? selectedFoods[selectedIndex]
                                                : null;
                                        return FoodItem(
                                          model: foods[index],
                                          selectedModel: selectedModel,
                                          index: index,
                                          isCategory: true,
                                          categoryId: widget.category!.id,
                                          callback: (model, index) {
                                            setState(() {
                                              foods[index] = model;
                                            });
                                          },
                                          kcalLeft: getKcalLeft(selectedModel),
                                        );
                                      }),
                                )
                              ],
                            ),
                          ),
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
                                        borderRadius:
                                            BorderRadius.circular(21.5)),
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
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.mainColor,
                                        borderRadius:
                                            BorderRadius.circular(21.5),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                        child: Text(R.string.tiep_tuc.tr(),
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
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
