import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../seach_food/search_food.dart';
import 'change_menu.dart';
import 'widgets/food_item_widget.dart';

class ChangeMenuPage extends StatefulWidget {
  const ChangeMenuPage({
    required this.preFoodModel,
    required this.hasSelectQuantity,
  });
  final FoodModel? preFoodModel;
  final bool hasSelectQuantity;

  @override
  _ChangeMenuPageState createState() => _ChangeMenuPageState();
}

class _ChangeMenuPageState extends State<ChangeMenuPage> {
  late final ChangeMenuCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ChangeMenuCubit(appRepository, initFood: widget.preFoodModel);
    _cubit.fetchSuggestFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<ChangeMenuCubit, ChangeMenuState>(
          listener: (context, state) {
            if (state is ChangeMenuFailure) {
              Message.showToastMessage(context, state.error);
            }
            if (state is ChangeMenuDone) {
              NavigationUtil.pop(context, result: _cubit.selectedFood);
            }
          },
          builder: (context, state) {
            if (state is ChangeMenuLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return CommonPage(
              title: R.string.choose_alternative_dish.tr(),
              background: R.drawable.bg_detail_pro,
              icon: Icons.clear_rounded,
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildPage(
                      foods: _cubit.suggestFoods,
                      emptyImage: R.drawable.img_empty_food_suggestion,
                      emptyText: R.string.suggest_food_empty.tr(),
                      onRefresh: () {
                        _cubit.fetchSuggestFood();
                      },
                    ),
                  ),
                ],
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
            SearchFoodPage(
              preFoodModel: _cubit.initFood,
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

  Widget _buildPage({
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
              preFoodModel: widget.preFoodModel,
              newFoodModel: foods[index],
              isSelected: foods[index].id == _cubit.initFood?.id,
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
}
