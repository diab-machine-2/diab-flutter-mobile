import 'dart:ui';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:medical/src/widget/Food/widget/food_of_category.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class CategoryFood extends StatefulWidget {
  final List<FoodModel> foods;
  CategoryFood({@required this.foods});
  @override
  _CategoryFoodState createState() => _CategoryFoodState();
}

class _CategoryFoodState extends State<CategoryFood>
    with AutomaticKeepAliveClientMixin<CategoryFood> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;

  List<FoodModel> selectedFoods = [];

  @override
  void initState() {
    super.initState();

    selectedFoods = [...SearchFoodController.of(context).selectedFoods];

    DartNotificationCenter.subscribe(
        channel: 'add_food_to_cart',
        observer: this,
        onNotification: (food) {
          setState(() {
            this.selectedFoods.removeWhere((element) => food.id == element.id);
            this.selectedFoods.add(food);
          });
        });

    DartNotificationCenter.subscribe(
        channel: 'remove_food_from_cart',
        observer: this,
        onNotification: (food) {
          if (food is FoodModel) {
            setState(() {
              selectedFoods.removeWhere((element) => element.id == food.id);
            });
          }
        });
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'add_food_to_cart', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'remove_food_from_cart', observer: this);
    super.dispose();
  }

  Future<bool> refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchFoodCategory(page: 1));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          List<FoodCategoryModel> model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchFoodCategory(page: 1));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is FoodCategoryLoaded) {
            model = state.model;
          }
          return model == null
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                      itemCount: model.length,
                      padding: EdgeInsets.all(0),
                      itemBuilder: (BuildContext context, int index) {
                        final category = model[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(category.name,
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ),
                            ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                itemCount: category.subCategories.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Container(
                                      height: 1, color: R.color.color0xffE5E5E5);
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  // final selectedIndex =
                                  //     selectedFoods.lastIndexWhere((element) =>
                                  //         element.categoryID ==
                                  //         category.subCategories[index].id);

                                  final foodOfCategory = selectedFoods.where(
                                      (element) =>
                                          element.foodCategoryId ==
                                          category.subCategories[index].id);
                                  double totalCalo = 0;
                                  double number = 0;
                                  foodOfCategory.forEach((element) {
                                    totalCalo +=
                                        element.quantity * element.calorie;
                                    number += element.quantity;
                                  });
                                  return GestureDetector(
                                    onTap: () {
                                      showListFood(
                                          category.subCategories[index]);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: foodOfCategory.length != 0
                                                ? R.color.color0xFFC3E8D3
                                                : R.color.transparent,
                                            border: Border.all(
                                                color:
                                                    foodOfCategory.length != 0
                                                        ? R.color.color0xff72CB9C
                                                        : R.color.transparent)),
                                        padding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 11,
                                            bottom: 11),
                                        child: Row(children: [
                                          Image.network(
                                              category.subCategories[index]
                                                      .image.url ??
                                                  '',
                                              width: 50,
                                              height: 50),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    category
                                                        .subCategories[index]
                                                        .name,
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                foodOfCategory.length == 0
                                                    ? SizedBox()
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4),
                                                        child: Text(
                                                            'Đã chọn $number món, ${formatNumber(totalCalo)} kcal',
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                      )
                                              ],
                                            ),
                                          )
                                        ])),
                                  );
                                })
                          ],
                        );
                      }));
        }));
  }

  showListFood(FoodSubCategoryModel category) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => FoodOfCategory(
          category: category, foods: selectedFoods, callback: (value) {}),
    );
  }
}
