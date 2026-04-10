import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';

class AllFoodTab extends StatefulWidget {
  final List<FoodModel> foods;
  final double? suggestKcal;

  AllFoodTab({
    required this.foods,
    required this.suggestKcal,
  });

  @override
  _AllFoodTabState createState() => _AllFoodTabState();
}

class _AllFoodTabState extends State<AllFoodTab>
    with AutomaticKeepAliveClientMixin<AllFoodTab>, Observer {
  @override
  bool get wantKeepAlive => true;

  List<FoodModel> recentFoods = [];
  List<FoodModel> allFoods = [];
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
      final futures = await Future.wait([
        FoodClient().fetchFoodLatest(),
        FoodClient().fetchFoodCategory(null, '', 1) // get all
      ]);
      final recentResult = futures[0] as dynamic; // FoodDataModel
      final allResult = futures[1] as dynamic;    // FoodCategoryDataModel
      
      recentFoods = recentResult.foods ?? [];
      allFoods = allResult.foods ?? [];
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
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: GẦN ĐÂY
            if (recentFoods.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Text('Gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: R.color.black)),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: recentFoods.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 1, color: R.color.color0xffE5E5E5);
                },
                itemBuilder: (context, index) {
                  final mModel = recentFoods[index];
                  final selectedIndex = selectedFoods.lastIndexWhere((element) => element.id == mModel.id);
                  final FoodModel? selectedModel = selectedIndex != -1 ? selectedFoods[selectedIndex] : null;

                  return FoodItem(
                    model: mModel,
                    selectedModel: selectedModel,
                    index: index,
                    isSearch: true,
                    categoryId: '',
                    callback: (model, idx) {},
                    kcalLeft: getKcalLeft(selectedModel),
                  );
                },
              ),
              // Spacer
              Container(height: 8, color: R.color.color0xffE5E5E5),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Text('Gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: R.color.black)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 84, right: 84, top: 20, bottom: 20),
                child: Image.asset(R.drawable.img_near_food_empty),
              ),
              Container(height: 8, color: R.color.color0xffE5E5E5),
            ],

            // SECTION: TẤT CẢ MÓN ĂN
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'Tất cả món ăn',
                style: TextStyle(
                  color: R.color.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(0),
              itemCount: allFoods.isEmpty ? 1 : allFoods.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container(height: 1, color: R.color.color0xffE5E5E5);
              },
              itemBuilder: (BuildContext context, int index) {
                if (allFoods.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 40),
                      child: Text('Chưa có món ăn nào', style: TextStyle(color: R.color.primaryGreyColor)),
                    ),
                  );
                }

                final mModel = allFoods[index];
                final selectedIndex = selectedFoods.lastIndexWhere((element) => element.id == mModel.id);
                final FoodModel? selectedModel = selectedIndex != -1 ? selectedFoods[selectedIndex] : null;

                return FoodItem(
                  model: mModel,
                  selectedModel: selectedModel,
                  index: index,
                  isSearch: true,
                  categoryId: '',
                  callback: (model, idx) {},
                  kcalLeft: getKcalLeft(selectedModel),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
