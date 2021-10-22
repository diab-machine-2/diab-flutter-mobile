import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/widget/category_food.dart';
import 'package:medical/src/widget/Food/widget/favorite_food.dart';
import 'package:medical/src/widget/Food/widget/food_choosen.dart';
import 'package:medical/src/widget/Food/widget/near_food.dart';
import 'package:medical/src/widget/Food/widget/search_food.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

typedef SearchFoodCallback = Function(List<FoodModel>);

class SearchFoodController extends StatefulWidget {
  final List<FoodModel>? foods;
  final SearchFoodCallback? callback;
  SearchFoodController({this.foods, this.callback});
  @override
  _SearchFoodControllerState createState() => _SearchFoodControllerState();

  static _SearchFoodControllerState? of(BuildContext context) {
    final _SearchFoodControllerState? navigator =
        context.findAncestorStateOfType<_SearchFoodControllerState>();
    return navigator;
  }
}

class _SearchFoodControllerState extends State<SearchFoodController>
    with SingleTickerProviderStateMixin, Observer {
  GlobalKey<CustomSegmentState> segmentKey = GlobalKey();
  TabController? _tabController;
  List<FoodModel> selectedFoods = [];
  @override
  void initState() {
    super.initState();
    selectedFoods = [...widget.foods!];
    _tabController = TabController(vsync: this, length: 3);
    _tabController!.addListener(() {
      if (_tabController!.previousIndex != _tabController!.index) {
        segmentKey.currentState!.jumpTo(_tabController!.index);
      }
    });
    Observable.instance.addObserver(this);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(children: [
                  CustomAppBar(
                      title: Text(
                        R.string.nhap_mon_an.tr(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: R.color.textDark),
                      ),
                      backgroundColor: R.color.transparent,
                      leadingIcon: IconButton(
                          splashColor: R.color.transparent,
                          highlightColor: R.color.transparent,
                          icon: Icon(Icons.close, color: R.color.textDark),
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (BuildContext context) {
                                  return SearchFood(
                                    foods: selectedFoods,
                                  );
                                }));
                      },
                      child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: R.color.grayComponentBorder)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(R.string.tim_kiem_mon_an.tr(),
                                    style: TextStyle(
                                        color: R.color.primaryGreyColor)),
                                Image.asset(R.drawable.ic_search,
                                    width: 24, height: 24)
                              ],
                            ),
                          )),
                    ),
                  ),
                  CustomSegment(
                      key: segmentKey,
                      onchange: (index) {
                        _tabController!.animateTo(index);
                      }),
                  SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 150),
                      child: TabBarView(controller: _tabController, children: [
                        NearFood(foods: selectedFoods),
                        FavoriteFood(foods: selectedFoods),
                        CategoryFood(foods: selectedFoods)
                      ]),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
        FoodChoosen(
            foods: widget.foods,
            callback: (data) {
              widget.callback!(data);
              Navigator.pop(context);
            })
      ]),
    );
  }
}

typedef SegmentOnchange = Function(int);

class CustomSegment extends StatefulWidget {
  CustomSegment({Key? key, this.onchange}) : super(key: key);
  final SegmentOnchange? onchange;
  @override
  CustomSegmentState createState() => CustomSegmentState();
}

class CustomSegmentState extends State<CustomSegment> {
  int segmentedControlValue = 0;

  jumpTo(int index) {
    setState(() {
      segmentedControlValue = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        SizedBox(width: 16.w),
        _buildButtonTabBar(
            title: R.string.mon_an_gan_day.tr(),
            isSelected: segmentedControlValue == 0,
            onTap: () {
              widget.onchange!(0);
              setState(() {
                segmentedControlValue = 0;
              });
            }),
        _buildButtonTabBar(
            title: R.string.mon_yeu_thich.tr(),
            isSelected: segmentedControlValue == 1,
            onTap: () {
              widget.onchange!(1);
              setState(() {
                segmentedControlValue = 1;
              });
            }),
        _buildButtonTabBar(
            title: R.string.danh_muc.tr(),
            isSelected: segmentedControlValue == 2,
            onTap: () {
              widget.onchange!(2);
              setState(() {
                segmentedControlValue = 2;
              });
            }),
        SizedBox(width: 16.w),
      ]),
    );
  }

  Widget _buildButtonTabBar(
      {required String title,
      required bool isSelected,
      required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 143.w,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: isSelected ? R.color.blue_6 : R.color.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? R.color.greenGradientBottom
                : R.color.captionColorGray,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
