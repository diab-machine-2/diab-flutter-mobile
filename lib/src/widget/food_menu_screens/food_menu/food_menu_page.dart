import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/intro_sample_menu/intro_sample_menu.dart';
import 'package:medical/src/widget/kcal_parameter/kcal_parameter.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widgets/update_required_widget.dart';
import '../change_menu/change_menu.dart';
import 'food_menu.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({this.createMenuRequest});

  final CreateMenuRequest? createMenuRequest;

  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  late final FoodMenuCubit _cubit;
  final RefreshController _controller = RefreshController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = FoodMenuCubit(appRepository);
    _cubit.createMenu(request: widget.createMenuRequest);
  }

  void updateKcal(BuildContext context) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => KcalParameterPage(
        isUpdate: true,
        callback: (request) {
          _cubit.createMenu(request: request);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<FoodMenuCubit, FoodMenuState>(
          listener: (context, state) {
            if (state is FoodMenuFailure) {
              Message.showToastMessage(context, state.error);
            }
            if (state is FoodMenuEmpty &&
                _cubit.userInfo?.hasFoodMenu != true) {
              NavigationUtil.replace(context, IntroSampleMenuPage());
            }
          },
          builder: (context, state) {
            if (state is FoodMenuLoading) {
              BotToast.showLoading();
            } else {
              _controller.refreshCompleted();
              BotToast.closeAllLoading();
            }
            return CommonPage(
              title: R.string.food_menu.tr(),
              background: R.drawable.bg_detail_pro,
              child: SmartRefresher(
                controller: _controller,
                onRefresh: () => _cubit.getTemplateDetail(isRefresh: true),
                child: _cubit.listDayFood.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(67.w, 100.h, 67.w, 52.h),
                            child: Image.asset(R.drawable.img_cooking),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28.w),
                            child: Text(
                              R.string.food_menu_empty.tr(),
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              updateKcal(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 24.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(
                                  width: 2,
                                  color: R.color.greenGradientBottom,
                                ),
                              ),
                              child: Text(
                                R.string.change_food_info.tr(),
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildTitle(
                              title: _cubit.menuResponseFood?.menuTitle ?? '',
                              onUpdateKcal: () {
                                updateKcal(context);
                              }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (index) {
                                return _buildDayOfTheWeekSingleButton(
                                    dayTitle: Utils.getDayInWeekTitle(index),
                                    isSelected:
                                        index == _cubit.currentDayInWeek,
                                    isEnable: !_cubit.isBasicUser || index <= 1,
                                    onTapEnabled: () {
                                      _cubit.onChangeDay(index);
                                    },
                                    onTapDisable: () {
                                      NavigationUtil.navigatePage(
                                        context,
                                        UpdateRequiredWidget(
                                          title: R.string.food_menu.tr(),
                                          description: R
                                              .string.food_menu_update_required
                                              .tr(),
                                        ),
                                      );
                                    });
                              }),
                            ),
                          ),
                          //Divider
                          Container(
                            margin: EdgeInsets.only(top: 10.h),
                            color: R.color.color0xffE5E5E5,
                            height: 1,
                            width: double.infinity,
                          ),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.h, 32.h),
                              children: [
                                ...List.generate(
                                    _cubit.listDayFood[_cubit.currentDayInWeek]
                                            ?.timeGroups?.length ??
                                        0, (index) {
                                  return _buildMealWidget(
                                      mealData: _cubit
                                          .listDayFood[_cubit.currentDayInWeek]
                                          ?.timeGroups?[index],
                                      onChangeFood: (foodDetail) async {
                                        final dynamic result =
                                            await NavigationUtil.navigatePage(
                                          context,
                                          ChangeMenuPage(
                                            preFoodModel: foodDetail?.foodModel,
                                            hasSelectQuantity: false,
                                          ),
                                        );
                                        if (result is FoodModel) {
                                          _cubit.changeFood(
                                              foodId: foodDetail?.id,
                                              newFoodModel: result);
                                        }
                                      });
                                }).toList(),
                                Visibility(
                                  visible: _cubit
                                          .menuResponseFood?.note?.isNotEmpty ??
                                      false,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 33.h,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          R.drawable.ic_info,
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: '${R.string.note.tr()} ',
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700),
                                              children: [
                                                TextSpan(
                                                  text: _cubit.menuResponseFood
                                                          ?.note ??
                                                      '',
                                                  style: TextStyle(
                                                      color: R.color.textDark,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 33.h),
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

  Widget _buildTitle({
    required String title,
    VoidCallback? onUpdateKcal,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 16.w, 34.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: R.color.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 50.w),
          GestureDetector(
            onTap: onUpdateKcal,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                  width: 2,
                  color: R.color.greenGradientBottom,
                ),
              ),
              child: Text(
                R.string.change_food_info.tr(),
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealWidget({
    required MenuResponseListdayfoodTimeGroups? mealData,
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)?
        onChangeFood,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: R.color.white,
        boxShadow: [
          BoxShadow(
            color: R.color.greenGradientBottom.withOpacity(0.08),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mealData?.mealName ?? '',
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  R.string.total_kcals.tr(args: [
                    '${num.parse(mealData?.totalKcal?.toStringAsFixed(3) ?? '0')}'
                  ]),
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.brightness_1,
                      size: 4.w, color: R.color.greenGradientBottom),
                ),
                Text(
                  R.string.total_starch.tr(args: [
                    '${num.parse(mealData?.totalGlucose?.toStringAsFixed(3) ?? '0')}'
                  ]),
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: mealData?.defaultFood?.isNotEmpty ?? false,
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                height: 1,
                color: R.color.notActiveGreen),
          ),
          ..._buildListFoodWidget(
              foods: mealData?.defaultFood, onChangeFood: onChangeFood),
        ],
      ),
    );
  }

  List<Widget> _buildListFoodWidget({
    required List<MenuResponseListdayfoodTimeGroupsDefaultFood?>? foods,
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)?
        onChangeFood,
  }) {
    if (foods == null || foods.isEmpty) return [];
    return List.generate((foods.length * 2) - 1, (index) {
      return index.isEven
          ? _buildSingleFoodWidget(
              foodDetail: foods[index ~/ 2],
              isSingleFoodMeal: foods.length == 1,
              onChangeFood: onChangeFood,
            )
          : Container(
              color: R.color.grayBorder,
              height: 1,
            );
    });
  }

  Widget _buildSingleFoodWidget({
    MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail,
    required bool isSingleFoodMeal,
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)?
        onChangeFood,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: foodDetail?.image?.url ?? '',
                    width: 50,
                    height: 50,
                    placeholder: (_, __) {
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorWidget: (_, __, ___) {
                      return Image.asset(R.drawable.ic_food_default);
                    },
                  )),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: foodDetail?.isDessert ?? false,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          R.string.dessert.tr(),
                          style: TextStyle(
                            color: R.color.green,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      foodDetail?.foodName ?? '',
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Visibility(
                      visible: isSingleFoodMeal,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '${foodDetail?.portion} ${foodDetail?.foodUnitName}',
                          style: TextStyle(
                            color: R.color.color0xff454649,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (onChangeFood != null) {
                    onChangeFood(foodDetail);
                  }
                },
                child: Image.asset(
                  R.drawable.ic_refresh,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Visibility(
            visible: !isSingleFoodMeal,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${foodDetail?.portion} ${foodDetail?.foodUnitName}',
                    style: TextStyle(
                      color: R.color.color0xff454649,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.brightness_1,
                        size: 4, color: R.color.greenGradientBottom),
                  ),
                  Text(
                    R.string.total_kcals
                        .tr(args: ['${(foodDetail?.calorie ?? 0.0) * (foodDetail?.portion ?? 0)}']),
                    style: TextStyle(
                      color: R.color.color0xff454649,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.brightness_1,
                        size: 4.w, color: R.color.greenGradientBottom),
                  ),
                  Text(
                    R.string.total_starch
                        .tr(args: ['${(foodDetail?.glucose ?? 0.0) * (foodDetail?.portion ?? 0)}']),
                    style: TextStyle(
                      color: R.color.color0xff454649,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Visibility(
            visible: foodDetail?.note?.isNotEmpty ?? false,
            child: RichText(
              text: TextSpan(
                text: '${R.string.attention.tr()} ',
                style: TextStyle(
                    color: R.color.attentionText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic),
                children: [
                  TextSpan(
                    text: foodDetail?.note,
                    style: TextStyle(
                        color: R.color.color0xff454649,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayOfTheWeekSingleButton({
    required String dayTitle,
    required bool isEnable,
    required bool isSelected,
    VoidCallback? onTapEnabled,
    VoidCallback? onTapDisable,
  }) {
    return GestureDetector(
      onTap: isEnable ? onTapEnabled : onTapDisable,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? R.color.mainColor : R.color.grayBorder,
          ),
          color: isEnable
              ? isSelected
                  ? R.color.main_6
                  : R.color.transparent
              : R.color.grayBorder,
        ),
        child: Text(
          dayTitle,
          style: TextStyle(
            color: isSelected ? R.color.mainColor : R.color.primaryGreyColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
