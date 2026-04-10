import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';

class FoodListByCategory extends StatefulWidget {
  final FoodSubCategoryModel? category;
  final List<FoodModel> foods;
  final double? suggestKcal;

  FoodListByCategory({
    this.category,
    required this.foods,
    required this.suggestKcal,
  });

  @override
  _FoodListByCategoryState createState() => _FoodListByCategoryState();
}

class _FoodListByCategoryState extends State<FoodListByCategory>
    with AutomaticKeepAliveClientMixin<FoodListByCategory>, Observer {
  @override
  bool get wantKeepAlive => true;

  List<FoodModel> fetchedFoods = [];
  List<FoodModel> selectedFoods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedFoods = [...widget.foods];
    Observable.instance.addObserver(this);
    loadData();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    final FoodModel? selectedModel = map?['food'];
    if (selectedModel != null) {
      if (notifyName == 'add_food_to_cart') {
        this
            .selectedFoods
            .removeWhere((element) => selectedModel.id == element.id);
        this.selectedFoods.add(selectedModel);
        setState(() {});
      }
      if (notifyName == 'remove_food_from_cart') {
        selectedFoods.removeWhere((element) => selectedModel.id == element.id);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  loadData() async {
    try {
      final result = await FoodClient()
          .fetchFoodCategory(widget.category?.id, '', 1); // Pass null categoryId and empty keyword to get ALL
      fetchedFoods = result.foods;
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
    });
    await loadData();
  }

  likeFood(FoodModel model, int index) {
    // optional logic
  }

  double? getKcalLeft(FoodModel? selectedModel) {
    if (widget.suggestKcal == null) return null;
    double totalSelectedKcal = 0;
    for (final food in selectedFoods) {
      totalSelectedKcal += food.totalKcal ?? 0;
    }
    final double kcalLeft = widget.suggestKcal! -
        totalSelectedKcal +
        (selectedModel?.totalKcal ?? 0);
    return max(kcalLeft, 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
            child: Text(
              widget.category?.name ?? 'Tất cả món ăn',
              style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(0),
              itemCount: fetchedFoods.isEmpty ? 1 : fetchedFoods.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container(height: 1, color: R.color.color0xffE5E5E5);
              },
              itemBuilder: (BuildContext context, int index) {
                if (fetchedFoods.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text('Chưa có món ăn nào', style: TextStyle(color: R.color.primaryGreyColor)),
                    ),
                  );
                }

                final mModel = fetchedFoods[index];
                final selectedIndex = selectedFoods.lastIndexWhere((element) => element.id == mModel.id);
                final FoodModel? selectedModel = selectedIndex != -1 ? selectedFoods[selectedIndex] : null;

                return FoodItem(
                  model: mModel,
                  selectedModel: selectedModel,
                  index: index,
                  isSearch: true,
                  categoryId: widget.category?.id ?? '',
                  callback: (model, idx) {
                    likeFood(model, idx);
                  },
                  kcalLeft: getKcalLeft(selectedModel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
