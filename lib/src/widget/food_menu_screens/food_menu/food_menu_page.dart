import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/food_menu_screens/change_menu/change_menu.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'food_menu.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage();

  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  late final FoodMenuCubit _cubit;
  int _selectedDay = 0;
  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = FoodMenuCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: R.string.food_menu.tr(),
        background: R.drawable.bg_detail_pro,
        child: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<FoodMenuCubit, FoodMenuState>(
            listener: (context, state) {},
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  children: [
                    _buildTitle(title: 'Thực đơn Dành cho Gymer 65Kg'),
                    _buildSelectDayButtonList(
                        selectedIndex: _selectedDay,
                        onSlectDay: (dayIndex) {
                          setState(() {
                            _selectedDay = dayIndex;
                          });
                        }),
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
                          _buildMealWidget(
                            mealName: 'Sáng',
                            totalKcal: 100,
                            totalStarch: 150,
                            onChangeFood: (){
                              NavigationUtil.navigatePage(context, const ChangeMenuPage());
                            }
                          ),
                          _buildMealWidget(
                            mealName: 'Trưa',
                            totalKcal: 100,
                            totalStarch: 150,
                          ),
                          _buildMealWidget(
                            mealName: 'Tối',
                            totalKcal: 100,
                            totalStarch: 150,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
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
                                    text: 'Gia vị nên được nêm vừa phải',
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitle({
    required String title,
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
            onTap: () {},
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

  Widget _buildSelectDayButtonList({
    required int selectedIndex,
    required Function(int index) onSlectDay,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          return _buildDayOfTheWeekSingleButton(
              dayTitle: Utils.getDayInWeekTitle(index),
              isSelected: index == selectedIndex,
              onTap: () {
                onSlectDay(index);
              });
        }),
      ),
    );
  }

  Widget _buildDayOfTheWeekSingleButton({
    required String dayTitle,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? R.color.mainColor : R.color.grayBorder,
          ),
          color: isSelected ? R.color.main_6 : Colors.transparent,
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

  Widget _buildMealWidget({
    required String mealName,
    required int totalKcal,
    required int totalStarch,
    VoidCallback? onChangeFood,
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
                    mealName,
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  R.string.total_kcals.tr(args: ['$totalKcal']),
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
                  R.string.total_starch.tr(args: ['$totalStarch']),
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
            visible: _selectedDay > 0,
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                height: 1,
                color: R.color.notActiveGreen),
          ),
          ..._buildListFoodWidget(numberOfFood: _selectedDay, onChangeFood: onChangeFood),
        ],
      ),
    );
  }

  List<Widget> _buildListFoodWidget({
    required int numberOfFood,
    VoidCallback? onChangeFood,
  }) {
    if (numberOfFood <= 0) return [];
    return List.generate((numberOfFood * 2) - 1, (index) {
      return index.isEven
          ? _buildSingleFoodWidget(
              imageUrl: 'https://picsum.photos/200/300',
              foodName: 'foodName',
              foodUnit: 'foodUnit',
              foodPortion: 1,
              totalKcal: 50,
              totalStarch: 50,
              isDessert: false,
              onChangeFood: onChangeFood,
            )
          : Container(
              color: R.color.grayBorder,
              height: 1,
            );
    });
  }

  Widget _buildSingleFoodWidget({
    required String imageUrl,
    required String foodName,
    required String foodUnit,
    required int foodPortion,
    required int totalKcal,
    required int totalStarch,
    required bool isDessert,
    String? note,
    VoidCallback? onChangeFood,
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
                    imageUrl: imageUrl,
                    width: 50,
                    height: 50,
                    errorWidget: (_, __, ___) {
                      //TODO: Tuyen add error image here
                      return Image.asset(R.drawable.ic_photo);
                    },
                  )),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: isDessert,
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
                      foodName,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onChangeFood,
                child: Image.asset(
                  R.drawable.ic_refresh,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  '$foodPortion $foodUnit',
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
                  R.string.total_kcals.tr(args: ['$totalKcal']),
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
                  R.string.total_starch.tr(args: ['$totalStarch']),
                  style: TextStyle(
                    color: R.color.color0xff454649,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Visibility(
            visible: note != null,
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
                    text: note,
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
}
