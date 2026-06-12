import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/widget/favorite_food.dart';
import 'package:medical/src/widget/Food/widget/food_choosen.dart';
import 'package:medical/src/widget/Food/widget/near_food.dart';
import 'package:medical/src/widget/Food/widget/search_food.dart';
import 'package:medical/src/widget/Food/widget/food_list_by_category.dart';
import 'package:medical/src/widget/Food/widget/all_food_tab.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

typedef SearchFoodCallback = Function(List<FoodModel>);

class SearchFoodController extends StatefulWidget {
  final List<FoodModel>? foods;
  final SearchFoodCallback? callback;
  final double? suggestKcal;
  final bool popAfterCallback;
  const SearchFoodController({this.foods, this.callback, this.suggestKcal, this.popAfterCallback = true});
  @override
  _SearchFoodControllerState createState() => _SearchFoodControllerState();

  static _SearchFoodControllerState? of(BuildContext context) {
    final _SearchFoodControllerState? navigator =
        context.findAncestorStateOfType<_SearchFoodControllerState>();
    return navigator;
  }
}

class _SearchFoodControllerState extends State<SearchFoodController>
    with Observer {
  List<FoodModel> selectedFoods = [];
  bool isLoadingCategories = true;
  List<FoodSubCategoryModel> dynamicCategories = [];
  int selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    selectedFoods = [...widget.foods!];
    Observable.instance.addObserver(this);
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final categories = await FoodClient().fetchCategory();
      List<FoodSubCategoryModel> temp = [];
      for (var cat in categories) {
        temp.addAll(cat.subCategories);
      }
      if (mounted) {
        setState(() {
          dynamicCategories = temp;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
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
    _pageController.dispose();
    super.dispose();
  }

  void jumpToCategory(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildCategoryBubble(
      {required String title,
      IconData? iconData,
      String? imageUrl,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.color.white,
              border: isSelected
                  ? Border.all(color: R.color.greenGradientBottom, width: 2)
                  : Border.all(color: R.color.color0xffE5E5E5, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? NetWorkImageWidget(imageUrl: imageUrl, width: 65, height: 65)
                : Icon(iconData ?? Icons.fastfood,
                    color: isSelected
                        ? R.color.greenGradientBottom
                        : R.color.primaryGreyColor,
                    size: 30),
          ),
          SizedBox(height: 8),
          Container(
            width: 75,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Container(
          color: R.color.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(children: [
                  CustomAppBar(
                    title: Text(
                      'Tìm món ăn',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.white),
                    ),
                    backgroundColor: R.color.greenGradientBottom,
                    leadingIcon: IconButton(
                        splashColor: R.color.transparent,
                        highlightColor: R.color.transparent,
                        icon: Icon(Icons.arrow_back, color: R.color.white),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    actions: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Hướng dẫn',
                              style: TextStyle(
                                color: R.color.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
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
                                    suggestKcal: widget.suggestKcal,
                                  );
                                }));
                      },
                      child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: R.color.grayComponentBorder)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              children: [
                                Image.asset(R.drawable.ic_search,
                                    width: 24,
                                    height: 24,
                                    color: R.color.primaryGreyColor),
                                SizedBox(width: 8),
                                Text('Tìm món ăn',
                                    style: TextStyle(
                                        color: R.color.primaryGreyColor)),
                              ],
                            ),
                          )),
                    ),
                  ),
                  isLoadingCategories
                      ? Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 16),
                              _buildCategoryBubble(
                                  title: 'Tất cả',
                                  iconData: Icons.restaurant,
                                  isSelected: selectedIndex == 0,
                                  onTap: () => jumpToCategory(0)),
                              SizedBox(width: 16),
                              _buildCategoryBubble(
                                  title: 'Yêu thích',
                                  iconData: Icons.favorite_border,
                                  isSelected: selectedIndex == 1,
                                  onTap: () => jumpToCategory(1)),
                              SizedBox(width: 16),
                              ...dynamicCategories.asMap().entries.map((e) {
                                int mappedIndex = e.key + 2;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _buildCategoryBubble(
                                    title: e.value.name ?? '',
                                    imageUrl: e.value.image.url ?? '',
                                    isSelected: selectedIndex == mappedIndex,
                                    onTap: () => jumpToCategory(mappedIndex),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                  SizedBox(height: 16),
                  
                  // MAIN LIST AREA
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 150),
                      child: isLoadingCategories 
                        ? Container()
                        : PageView.builder(
                            physics: const NeverScrollableScrollPhysics(), // Disable swipe because we have a scrollable top bar, swiping could conflict with inner lists
                            controller: _pageController,
                            onPageChanged: (index) {
                               setState(() {
                                 selectedIndex = index;
                               });
                            },
                            itemCount: 2 + dynamicCategories.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return AllFoodTab(
                                  foods: selectedFoods,
                                  suggestKcal: widget.suggestKcal,
                                );
                              }
                              if (index == 1) {
                                return FavoriteFood(
                                  foods: selectedFoods,
                                  suggestKcal: widget.suggestKcal,
                                );
                              }
                              final category = dynamicCategories[index - 2];
                              return FoodListByCategory(
                                category: category,
                                foods: selectedFoods,
                                suggestKcal: widget.suggestKcal,
                              );
                            },
                          ),
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
              if (widget.popAfterCallback) {
                Navigator.pop(context);
              }
            })
      ]),
    );
  }
}
