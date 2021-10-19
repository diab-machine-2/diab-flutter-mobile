import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';

import '../change_menu/widgets/food_item_widget.dart';
import 'category_menu.dart';

class CategoryMenuPage extends StatefulWidget {
  const CategoryMenuPage({
    required this.preFoodModel,
    required this.category,
    required this.onTapYes,
    required this.hasSelectQuantity,
  });

  final FoodModel? preFoodModel;
  final FoodSubCategoryModel category;
  final Function(FoodModel foodModel) onTapYes;
  final bool hasSelectQuantity;

  @override
  _CategoryMenuPageState createState() => _CategoryMenuPageState();
}

class _CategoryMenuPageState extends State<CategoryMenuPage> {
  late final CategoryMenuCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = CategoryMenuCubit(
      repository: appRepository,
      category: widget.category,
    );
    _cubit.fetchFoodCategory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<CategoryMenuCubit, CategoryMenuState>(
        listener: (context, state) {
          if (state is CategoryMenuFailure) {
            Message.showToastMessage(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is CategoryMenuLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Scaffold(
              backgroundColor: R.color.transparent,
              body: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 3 / 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: R.color.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: Text(
                          '${R.string.chon_mon.tr()} ${widget.category.name ?? ''}',
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _cubit.foods.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 1,
                              color: R.color.color0xffE5E5E5,
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return FoodItemWidget(
                              preFoodModel: widget.preFoodModel,
                              newFoodModel: _cubit.foods[index],
                              isSelected: _cubit.foods[index].id ==
                                  widget.preFoodModel?.id,
                              onFavorite: () {
                                _cubit.toogleFavorite(
                                  index,
                                );
                              },
                              onConfirm: (foodModel) {
                                widget.onTapYes(foodModel);
                                NavigationUtil.pop(context);
                              },
                              hasSelectQuantity: widget.hasSelectQuantity,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.grayBorder,
                                    borderRadius: BorderRadius.circular(21.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.cancel.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
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
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.tiep_tuc.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
