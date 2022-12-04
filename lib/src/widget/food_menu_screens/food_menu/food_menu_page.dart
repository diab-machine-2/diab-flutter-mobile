import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Food/widget/food_info.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widgets/update_required_widget.dart';
import '../../HbA1C/widget/description/description_detail.dart';
import '../change_menu/change_menu.dart';
import '../intro_sample_menu/intro_sample_menu.dart';
import '../kcal_parameter/kcal_parameter.dart';
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
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "sample_menu", 
      screenClass: "FoodMenuPage"
    );
  }

  void updateKcal(BuildContext context) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => KcalParameterPage(
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
            if (state is FoodMenuEmpty && _cubit.userInfo?.hasFoodMenu != true) {
              NavigationUtil.replace(context, const IntroSampleMenuPage());
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
              appBarAction: GestureDetector(
                onTap: () async {
                  showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.8),
                  useSafeArea: false,
                  context: context,
                  builder: (_) => DetailDescription(
                      input: false, isShowTitle: true, titleFontSize: 18, data: ShortGuiModel(content1: "", content2: "", content3: "", 
                      content4: """<p></p>
<ul style="list-style-type:disc">
    <li style="margin-left: 0in;"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;color: rgb(0, 26, 51);'>Hướng dẫn chẩn đo&aacute;n v&agrave; điều trị đ&aacute;i th&aacute;o đường t&iacute;p 2- Bộ Y tế (5481/QĐ-BYT)</span></li>
    <li style="margin-left: 0in;"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;color: rgb(0, 26, 51);'>Standards of Medical Care in Diabetes (2021). Diabetes Care 1 January 2021; 44 (Supplement_1): S1&ndash;S2. <a data-saferedirecturl="https://www.google.com/url?q=https://doi.org/10.2337/dc21-Sint&source=gmail&ust=1651830131900000&usg=AOvVaw1M_UQEFpp5Naj8xOf9mDd-" href="https://doi.org/10.2337/dc21-Sint" style='color: rgb(17, 85, 204);font-family: "Segoe UI", sans-serif;' target="_blank">https://doi.org/10.2337/dc21-Sint</a></span></li>
    <li style="margin-left: 0in;"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;color: rgb(0, 26, 51);'>Th&ocirc;ng tin dinh dưỡng m&oacute;n ăn được tham khảo từ:</span>
        <ul style="list-style-type:circle">
            <li style="margin-left: 0in;"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;color: rgb(0, 26, 51);'>Bảng th&agrave;nh phần thực phẩm Việt Nam &ndash; Nh&agrave; xuất bản Y Học</span></li>
            <li style="margin-left: 0in;"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;color: rgb(0, 26, 51);'>United States Department of Agriculture (USDA) - <a data-saferedirecturl="https://www.google.com/url?q=https://fdc.nal.usda.gov/fdc-app.html%23/&source=gmail&ust=1651830131900000&usg=AOvVaw3BIpUJWlKkgFfr4_ml0hlJ" href="https://fdc.nal.usda.gov/fdc-app.html#/" style='color: rgb(17, 85, 204);font-family: "Segoe UI", sans-serif;' target="_blank">https://fdc.nal.usda.gov/fdc-app.html#/</a></span></li>
        </ul>
    </li>
    <li style="margin-left: 0in; color: rgb(0, 26, 51);"><span style='font-size:15px;font-family: "Segoe UI", sans-serif;'>Kiến thức chuy&ecirc;n gia của BS CKI &amp; chuy&ecirc;n gia dinh dưỡng Trần Vũ Lan Hương v&agrave; c&aacute;c cộng sự.</span></li>
</ul>"""
                    ), title: "Thực đơn mẫu của chúng tôi được xây dựng dựa trên cơ sở"),
                );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset(R.drawable.ic_help_circle, width: 24, height: 24),
                ),
              ),
              child: state is FoodMenuLoading || _cubit.listDayFood == null
                  ? Center(
                      child: (state is FoodMenuLoading) ? const SizedBox() : const CircularProgressIndicator(),
                    )
                  : SmartRefresher(
                      controller: _controller,
                      onRefresh: () => _cubit.getTemplateDetail(isRefresh: true),
                      child: _cubit.listDayFood?.isEmpty == true
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(67, 100, 67, 52),
                                  child: Image.asset(R.drawable.img_cooking),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                    R.string.food_menu_empty.tr(),
                                    style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16,
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
                                    margin: const EdgeInsets.only(top: 24),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                        fontSize: 14,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(7, (index) {
                                      return _buildDayOfTheWeekSingleButton(
                                          dayTitle: Utils.getDayInWeekTitle(index),
                                          isSelected: index == _cubit.currentDayInWeek,
                                          isEnable: !_cubit.isBasicUser || index <= 1,
                                          onTapEnabled: () {
                                            _cubit.onChangeDay(index);
                                          },
                                          onTapDisable: () {
                                            NavigationUtil.navigatePage(
                                              context,
                                              UpdateRequiredWidget(
                                                title: R.string.food_menu.tr(),
                                                description: R.string.food_menu_update_required.tr(),
                                              ),
                                            );
                                          });
                                    }),
                                  ),
                                ),
                                //Divider
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  color: R.color.color0xffE5E5E5,
                                  height: 1,
                                  width: double.infinity,
                                ),
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                                    children: [
                                      ...List.generate(
                                          _cubit.listDayFood?[_cubit.currentDayInWeek]?.timeGroups?.length ?? 0,
                                          (index) {
                                        return _buildMealWidget(
                                            mealData: _cubit.listDayFood?[_cubit.currentDayInWeek]?.timeGroups?[index],
                                            onChangeFood: (foodDetail) async {
                                              if(foodDetail?.foodMenuCode == null){
                                                
                                              }
                                              final dynamic result = await NavigationUtil.navigatePage(
                                                context,
                                                ChangeMenuPage(
                                                  preFoodModel: foodDetail?.foodModel,
                                                  hasSelectQuantity: false,
                                                  dateCode: foodDetail?.dateCode,
                                                  timeCode: foodDetail?.timeCode,
                                                ),
                                              );
                                              if (result is FoodModel) {
                                                _cubit.changeFood(foodId: foodDetail?.id, newFoodModel: result);
                                              }
                                            });
                                      }).toList(),
                                      Visibility(
                                        visible: _cubit.menuResponseFood?.note?.isNotEmpty ?? false,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 33,
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
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700),
                                                    children: [
                                                      TextSpan(
                                                        text: _cubit.menuResponseFood?.note ?? '',
                                                        style: TextStyle(
                                                            color: R.color.textDark,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w400),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 33),
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
      padding: const EdgeInsets.fromLTRB(20, 28, 16, 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: R.color.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 50),
          GestureDetector(
            onTap: onUpdateKcal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  fontSize: 14,
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
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)? onChangeFood,
  }) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mealData?.mealName ?? '',
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    R.string.total_kcals.tr(args: ['${num.parse(mealData?.totalKcal?.toStringAsFixed(1) ?? '0')}']),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.brightness_1, size: 4, color: R.color.greenGradientBottom),
                  ),
                  Text(
                    R.string.total_starch.tr(args: ['${num.parse(mealData?.totalGlucose?.toStringAsFixed(1) ?? '0')}']),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: mealData?.defaultFood?.isNotEmpty ?? false,
              child:
                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 1, color: R.color.notActiveGreen),
            ),
            ..._buildListFoodWidget(foods: mealData?.defaultFood, onChangeFood: onChangeFood),
          ],
        ),
    );
  }

  List<Widget> _buildListFoodWidget({
    required List<MenuResponseListdayfoodTimeGroupsDefaultFood?>? foods,
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)? onChangeFood,
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
    Function(MenuResponseListdayfoodTimeGroupsDefaultFood? foodDetail)? onChangeFood,
  }) {
    return GestureDetector(
      onTap: () async {
   //     showFoodInfo(context, foodDetail?.foodModel);
      },
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  child: NetWorkImageWidget(
                    imageUrl: foodDetail?.image?.url,
                    width: 50,
                    height: 50,
                  )),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: foodDetail?.isDessert ?? false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          R.string.dessert.tr(),
                          style: TextStyle(
                            color: R.color.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      foodDetail?.foodName ?? '',
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Visibility(
                      visible: isSingleFoodMeal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${foodDetail?.portion?.toStringAsFixed(1)} ${foodDetail?.foodUnitName}',
                          style: TextStyle(
                            color: R.color.grey_1,
                            fontSize: 16,
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
          const SizedBox(height: 8),
          Visibility(
            visible: !isSingleFoodMeal,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${foodDetail?.portion?.toStringAsFixed(1)} ${foodDetail?.foodUnitName}',
                    style: TextStyle(
                      color: R.color.grey_1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.brightness_1, size: 4, color: R.color.greenGradientBottom),
                  ),
                  Text(
                    R.string.total_kcals.tr(args: [
                      '${num.parse(((foodDetail?.calorie ?? 0.0) * (foodDetail?.portion ?? 0.0)).toStringAsFixed(1))}'
                    ]),
                    style: TextStyle(
                      color: R.color.grey_1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.brightness_1, size: 4, color: R.color.greenGradientBottom),
                  ),
                  Text(
                    R.string.total_starch.tr(args: [
                      '${num.parse(((foodDetail?.glucose ?? 0.0) * (foodDetail?.portion ?? 0.0)).toStringAsFixed(1))}'
                    ]),
                    style: TextStyle(
                      color: R.color.grey_1,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Visibility(
            visible: foodDetail?.note?.isNotEmpty ?? false,
            child: RichText(
              text: TextSpan(
                text: '${R.string.attention.tr()} ',
                style: TextStyle(
                    color: R.color.attentionText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic),
                children: [
                  TextSpan(
                    text: foodDetail?.note,
                    style: TextStyle(
                        color: R.color.grey_1, fontSize: 14, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      ),
    );
  }

  showFoodInfo(BuildContext context, FoodModel? model) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => FoodInfo(
          model: model,
        //  selectedModel: selectedModel,
          callback: (value) {},
          kcalLeft: null,
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
        padding: const EdgeInsets.all(8),
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
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
