import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/stack_loading_view.dart';

import '../category_menu/category_menu.dart';
import '../seach_food/search_food.dart';
import 'change_menu.dart';
import 'models/tab_item_enum.dart';
import 'widgets/food_item_widget.dart';
import 'widgets/tab_bar_widget.dart';

class ChangeMenuPage extends StatefulWidget {
  const ChangeMenuPage({
    required this.selectedFood,
    required this.hasSelectQuantity,
  });
  final FoodModel? selectedFood;
  final bool hasSelectQuantity;

  @override
  _ChangeMenuPageState createState() => _ChangeMenuPageState();
}

class _ChangeMenuPageState extends State<ChangeMenuPage> {
  late final ChangeMenuCubit _cubit;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ChangeMenuCubit(appRepository);
    _cubit.fetchFoodLatest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<ChangeMenuCubit, ChangeMenuState>(
          listener: (context, state) {
            if (state is ChangeMenuDone) {
              NavigationUtil.pop(context, result: _cubit.selectedFood);
            }
          },
          builder: (context, state) {
            return StackLoadingView(
              visibleLoading: state is ChangeMenuLoading,
              child: CommonPage(
                title: R.string.choose_alternative_dish.tr(),
                background: R.drawable.bg_detail_pro,
                icon: Icons.clear_rounded,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 27),
                      child: TabBarWidget(
                        initTab: TabItem.suggest,
                        onSelect: (TabItem tab) {
                          _cubit.refreshTab(newTab: tab);
                          _controller.jumpToPage(tab.index);
                        },
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildTab(
                            foods: _cubit.suggestFoods,
                            emptyImage: R.drawable.img_empty_food_suggestion,
                            emptyText: R.string.suggest_food_empty.tr(),
                            onRefresh: () {
                              _cubit.fetchSuggestFood();
                            },
                          ),
                          _buildTab(
                            foods: _cubit.recentlyFoods,
                            emptyImage: R.drawable.img_near_food_empty,
                            onRefresh: () {
                              _cubit.fetchFoodLatest();
                            },
                          ),
                          _buildTab(
                            foods: _cubit.favoriteFoods,
                            emptyImage: R.drawable.img_favorite_food_empty,
                            onRefresh: () {
                              _cubit.fetchFoodFavorite();
                            },
                          ),
                          _buildCategoryList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      child: GestureDetector(
        onTap: () async {
          await NavigationUtil.navigatePage(
            context,
            SeachFoodPage(
              selectedFood: widget.selectedFood,
              onConfirm: (selectedFood) {
                _cubit.onChoseFood(
                  newSelectedFood: selectedFood,
                );
              },
              hasSelectQuantity: widget.hasSelectQuantity,
            ),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: R.color.grayComponentBorder)),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.tim_kiem_mon_an.tr(),
                  style: TextStyle(
                    color: R.color.primaryGreyColor,
                  ),
                ),
                Image.asset(
                  R.drawable.ic_search,
                  width: 24,
                  height: 24,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required List<FoodModel> foods,
    required String emptyImage,
    String? emptyText,
    required VoidCallback onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh.call();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(0),
        itemCount: foods.isEmpty ? 1 : foods.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(height: 1, color: R.color.color0xffE5E5E5);
        },
        itemBuilder: (BuildContext context, int index) {
          if (foods.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 84, right: 84, top: 100),
              child: Column(
                children: [
                  Image.asset(emptyImage),
                  Visibility(
                    visible: emptyText != null,
                    child: Text(
                      emptyText ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return FoodItemWidget(
              foodModel: foods[index],
              isSelected: foods[index].id == widget.selectedFood?.id,
              onFavorite: () {
                _cubit.toogleFavorite(index);
              },
              onConfirm: (foodModel) {
                _cubit.onChoseFood(
                  newSelectedFood: foodModel,
                );
              },
              hasSelectQuantity: widget.hasSelectQuantity,
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        _cubit.fetchFoodCategory();
      },
      child: ListView.builder(
        itemCount: _cubit.categoryFoods.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          final FoodCategoryModel category = _cubit.categoryFoods[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category.name ?? '',
                  style: TextStyle(
                      color: R.color.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: category.subCategories.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 1, color: R.color.color0xffE5E5E5);
                },
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      showListFood(category.subCategories[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: R.color.transparent,
                        border: Border.all(color: R.color.transparent),
                      ),
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 11,
                        bottom: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  category.subCategories[index].image.url ?? '',
                              width: 50,
                              height: 50,
                              placeholder: (_, __) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorWidget: (_, __, ___) {
                                return Image.asset(R.drawable.ic_food_default);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.subCategories[index].name!,
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

  showListFood(FoodSubCategoryModel category) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => CategoryMenuPage(
        selectedFood: widget.selectedFood,
        category: category,
        onTapYes: (foodModel) {
          _cubit.onChoseFood(
            newSelectedFood: foodModel,
          );
        },
        hasSelectQuantity: widget.hasSelectQuantity,
      ),
    );
  }
}
