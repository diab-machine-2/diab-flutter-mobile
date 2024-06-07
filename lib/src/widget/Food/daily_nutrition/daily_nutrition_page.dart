import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/BloodSugar/add_bloodSugar.dart';
import 'package:medical/src/widget/Food/widget/time_frame_food.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/food_menu_screens/change_menu/change_menu.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../widgets/btn_add_photo.dart';
import '../search_food_controller.dart';
import '../widget/food_info.dart';
import 'daily_nutrition.dart';

class DailyNutritionPage extends StatefulWidget {
  DailyNutritionPage({required this.type, required this.id, this.goalId});

  final String? type;
  final String? id;
  final String? goalId;

  @override
  _DailyNutritionPageState createState() => _DailyNutritionPageState();
}

class _DailyNutritionPageState extends State<DailyNutritionPage>
    with SingleTickerProviderStateMixin {
  late final DailyNutritionCubit _cubit;

  final TextEditingController _controllerNote = TextEditingController();
  final TextEditingController _controllerKcal = TextEditingController(text: '');

  late AnimationController _animtionController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  int clickTime = 0;
  @override
  void initState() {
    final AppRepository appRepository = AppRepository();
    _cubit = DailyNutritionCubit(appRepository, widget.goalId ?? '');
    _cubit.getInitialData(type: widget.type, id: widget.id);
    super.initState();
    firebaseSetup();
    animationFocus();
    initData();
  }

  void initData() async {
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.FOOD.index];
  }

  animationFocus() {
    _animtionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 10.0, end: AppMediaQuery.deviceHeight / 3)
        .animate(_animtionController)
      ..addListener(() {
        setState(() {});
      });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animtionController.forward();
      } else {
        _animtionController.reverse();
      }
    });
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "kpi_nutrition_add",
      screenClass: "DailyNutritionPage",
    );
    await TrackingManager.analytics.logEvent(
      name: 'kpi_add_begin',
      parameters: {
        "screen_name": 'kpi_nutrition_add',
        'object_type': 'kpi_nutrition',
        'object_title': 'Chỉ số dinh dưỡng'
      },
    );
    AppSettings.currentScreenName = 'kpi_add_begin';
  }

  showGuide(BuildContext context) async {
    Description.showTooltip(context,
        data: _cubit.des!,
        title: R.string.che_do_dinh_duong_benh_tieu_duong.tr());
    clickTime = clickTime + 1;
    await AppSettings.setValueOfClickShortGuideIndex(
        ScreenList.FOOD.index, clickTime);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          _showDialogSave();
          return false;
        },
        child: Scaffold(
          body: BlocProvider(
            create: (context) => _cubit,
            child: BlocConsumer<DailyNutritionCubit, DailyNutritionState>(
              listener: (context, state) {
                if (state is DailyNutritionFailure) {
                  Message.showToastMessage(context, state.error);
                }
                if (state is DailyNutritionSubmitSuccess) {
                  NavigationUtil.pop(context);
                }
                if (state is DailyNutritionFillData) {
                  _controllerNote.text = _cubit.notes;
                  _controllerKcal.text = _cubit.totalKcalText;
                }
              },
              builder: (context, state) {
                if (state is DailyNutritionLoading) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }
                return CommonPage(
                  title: R.string.cap_nhat_chi_so_dinh_duong.tr(),
                  background: R.drawable.bg_splash,
                  onTapBack: _showDialogSave,
                  appBarAction: GestureDetector(
                    onTap: () async {
                      if (clickTime >= 2) {
                        await showGuide(context);
                      } else {
                        setState(() {
                          _cubit.showDetailToggle();
                          clickTime = clickTime + 1;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _cubit.showDetail
                          ? Image.asset(R.drawable.ic_help_circle_active,
                              width: 24, height: 24)
                          : Image.asset(R.drawable.ic_help_circle,
                              width: 24, height: 24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const SizedBox(height: 16),
                            Visibility(
                              visible: _cubit.showDetail && clickTime < 2,
                              child: Description(
                                  input: true,
                                  isCreateData: true,
                                  data: _cubit.des,
                                  titleDetail: R
                                      .string.che_do_dinh_duong_benh_tieu_duong
                                      .tr()),
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    height: 136,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: R.color.color0xffF4DBBD,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Image.asset(R.drawable.img_food_person,
                                        width: 113, height: 148),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${R.string.luong_calo_ban_da_nap.tr()}:'),
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                formatNumber(
                                                    _cubit.totalKcalNumber),
                                                style: TextStyle(
                                                  color: R.color.black,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3),
                                                child: Text(
                                                  R.string.kcal.tr(),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            _buildItemLayout(
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      barrierColor: R.color.color0xff003F38
                                          .withOpacity(0.5),
                                      context: context,
                                      builder: (_) => DateMultiPicker(
                                        initDate: _cubit.selectedDate,
                                        callback: (date) {
                                          if (date != null) {
                                            _cubit.selectedDate = date;
                                            _cubit.loadTimeFrame();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: R.color.transparent,
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Image.asset(R.drawable.ic_calendar,
                                                width: 24, height: 24),
                                            const SizedBox(width: 8),
                                            Text(
                                                convertToUTC(
                                                    _cubit.selectedDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    'HH:mm - dd/MM/yyyy'),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ]),
                                      const SizedBox(height: 16),
                                      Container(
                                          height: 1,
                                          color: R.color.color0xffE5E5E5),
                                      const SizedBox(height: 8),
                                    ]),
                                  ),
                                )
                              ]),
                            ),
                            _buildItemLayout(
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    showActionFilter(context);
                                  },
                                  child: Container(
                                    color: R.color.transparent,
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(R.drawable.ic_clock,
                                              width: 24, height: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            _cubit.selectedTimeFrame == null
                                                ? R.string.chon_khung_gio.tr()
                                                : _cubit.selectedTimeFrame!
                                                        .name ??
                                                    '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                          height: 1,
                                          color: R.color.color0xffE5E5E5),
                                      const SizedBox(height: 8),
                                    ]),
                                  ),
                                )
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(children: [
                                CupertinoSwitch(
                                  activeColor: const Color(0xff008479),
                                  value: _cubit.addTotalCalo,
                                  onChanged: (value) {
                                    _cubit.onToggleButton(value);
                                    _controllerKcal.text = '';
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(R.string.input_calories.tr(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600))
                              ]),
                            ),
                            if (!_cubit.addTotalCalo)
                              _buildItemLayout(
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            addFood(context);
                                          },
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(R.drawable.ic_bowl,
                                                    width: 24, height: 24),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      R.drawable
                                                          .ic_circle_plus_exe,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      R.string.them_mon_an.tr(),
                                                      style: TextStyle(
                                                        color:
                                                            R.color.mainColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                            height: 1,
                                            color: R.color.color0xffE5E5E5),
                                        Visibility(
                                          visible: _cubit.showFoodFromMenuTitle,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Text(
                                              '${R.string.food_from_menu.tr()}:',
                                              style: TextStyle(
                                                color: R.color.accentColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListView.separated(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                _cubit.selectedFoods.length,
                                            separatorBuilder: (context, index) {
                                              return Container(
                                                  height: 1,
                                                  color:
                                                      R.color.color0xffD6D8E0);
                                            },
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final String quantity =
                                                  '${roundAsFixed(_cubit.selectedFoods[index].portion ?? 0)}';
                                              final String kcal = formatNumber(
                                                  (_cubit.selectedFoods[index]
                                                              .portion ??
                                                          0) *
                                                      _cubit
                                                          .selectedFoods[index]
                                                          .calorie!);
                                              final String detail =
                                                  '${R.string.da_an.tr()} $quantity ${_cubit.selectedFoods[index].unit}, $kcal ${R.string.kcal.tr()}';
                                              return GestureDetector(
                                                onTap: () {
                                                  //    showFoodInfo(context, _cubit.selectedFoods[index]);
                                                },
                                                child: Container(
                                                  color: R.color.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      NetWorkImageWidget(
                                                        imageUrl: _cubit
                                                                .selectedFoods[
                                                                    index]
                                                                .image!
                                                                .url ??
                                                            '',
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  _cubit
                                                                      .selectedFoods[
                                                                          index]
                                                                      .name!,
                                                                  style: TextStyle(
                                                                      color: R
                                                                          .color
                                                                          .textDark,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                detail,
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .textDark,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: _cubit
                                                                .selectedFoods[
                                                                    index]
                                                                .mealId
                                                                ?.isNotEmpty ==
                                                            true,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            if (_cubit
                                                                        .selectedFoods[
                                                                            index]
                                                                        .foodMenuCode ==
                                                                    null &&
                                                                _cubit
                                                                    .listFoodMenu
                                                                    .isNotEmpty) {
                                                              _cubit
                                                                  .selectedFoods[
                                                                      index]
                                                                  .foodMenuCode = _cubit
                                                                      .listFoodMenu[
                                                                          0]
                                                                      ?.foodMenuCode ??
                                                                  '000000000';
                                                            }

                                                            final dynamic
                                                                result =
                                                                await NavigationUtil
                                                                    .navigatePage(
                                                              context,
                                                              ChangeMenuPage(
                                                                preFoodModel:
                                                                    _cubit.selectedFoods[
                                                                        index],
                                                                hasSelectQuantity:
                                                                    true,
                                                                dateCode:
                                                                    'T${_cubit.selectedDate.weekday + 1}',
                                                                timeCode: _cubit
                                                                        .selectedFoods[
                                                                            index]
                                                                        .timeCode ??
                                                                    _cubit
                                                                        .timeCode,
                                                              ),
                                                            );
                                                            if (result
                                                                is FoodModel) {
                                                              await _cubit
                                                                  .changeFood(
                                                                      newFoodModel:
                                                                          result);
                                                              _cubit.selectedFoods[
                                                                      index] =
                                                                  result;
                                                              if (result.mealId
                                                                      ?.isNotEmpty ==
                                                                  true) {
                                                                _cubit.foodSuggestByMenu[
                                                                        index] =
                                                                    result;
                                                              }

                                                              _cubit.refresh();
                                                            }
                                                          },
                                                          child: Image.asset(
                                                            R.drawable
                                                                .ic_refresh,
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _cubit.selectedFoods
                                                              .removeAt(index);
                                                          _cubit
                                                              .calculatorCalo();
                                                          _cubit.refresh();
                                                        },
                                                        child: Image.asset(
                                                          R.drawable
                                                              .ic_trash_red,
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            })
                                      ]),
                                ),
                              )
                            else
                              _buildItemLayout(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(R.string.luong_calo_ban_da_nap,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 24),
                                      TextField(
                                          controller: _controllerKcal,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'[-.]'))
                                          ],
                                          enableInteractiveSelection: false,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                          decoration: InputDecoration(
                                              hintText: R
                                                  .string.luong_calo_ban_da_nap,
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 8),
                                              counterText: '',
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff666666))),
                                          onChanged: (value) {
                                            _cubit.totalKcalText = value;
                                            _cubit.calculatorCalo();
                                          }),
                                      Container(
                                          height: 1,
                                          color: const Color(0xffE5E5E5)),
                                    ]),
                              ),
                            _buildItemLayout(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_note_text,
                                        width: 24, height: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      R.string.ghi_chu.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ]),
                                  const SizedBox(height: 24),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    child: TextField(
                                        focusNode: _focusNode,
                                        controller: _controllerNote,
                                        onChanged: (text) {
                                          _cubit.notes = text;
                                        },
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        decoration: InputDecoration(
                                            hintText: R
                                                .string.nhap_ghi_chu_cua_ban
                                                .tr(),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    bottom: 8),
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    R.color.primaryGreyColor))),
                                  ),
                                  Container(
                                      height: 1,
                                      color: R.color.color0xffE5E5E5),
                                  const SizedBox(height: 8),
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: _cubit.files.length + 1,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (index == _cubit.files.length) {
                                            showActionSheet(context);
                                          }
                                        },
                                        child: index == _cubit.files.length
                                            ? ButtonAddPhoto()
                                            : Stack(
                                                alignment:
                                                    AlignmentDirectional.topEnd,
                                                children: [
                                                  Positioned.fill(
                                                      child: _cubit.files[index]
                                                              is XFile
                                                          ? Image.file(
                                                              File(_cubit
                                                                  .files[index]
                                                                  .path),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : NetWorkImageWidget(
                                                              imageUrl: _cubit
                                                                  .files[index]
                                                                  .url,
                                                            )),
                                                  IconButton(
                                                    icon: Image.asset(
                                                        R.drawable.ic_trash),
                                                    onPressed: () {
                                                      _cubit.removeFood(index);
                                                    },
                                                  )
                                                ],
                                              ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: _animation.value),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (widget.type == 'input')
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            _cubit.submitData();
                          },
                          child: SafeArea(
                            top: false,
                            child: Container(
                              height: 48,
                              width: 195,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: R.color.mainColor,
                                borderRadius: BorderRadius.circular(200),
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
                                  R.string.save.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SafeArea(
                          top: false,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showDialogDelete(context);
                                  },
                                  child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          border: Border.all(
                                              color: R.color.red, width: 2)),
                                      child: Center(
                                        child: Text(R.string.xoa_du_lieu.tr(),
                                            style: TextStyle(
                                                color: R.color.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    _cubit.editData(widget.id);
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 164,
                                    decoration: BoxDecoration(
                                        color: R.color.mainColor,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text(R.string.save.tr(),
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
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

  Widget _buildItemLayout({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: child,
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => FoodTimeFrame(
        selected: _cubit.selectedTimeFrame,
        callback: (value) {
          _cubit.selectedTimeFrame = value;
          _cubit.getSuggestFood();
        },
      ),
    );
  }

  addFood(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return SearchFoodController(
            foods: _cubit.selectedFoods,
            callback: (foods) {
              _cubit.selectedFoods = foods;
              _cubit.calculatorCalo();
              _cubit.refresh();
            },
            suggestKcal: _cubit.totalKcalInFoodMenu,
          );
        },
      ),
    );
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_cubit.files.length < Const.maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                  const SizedBox(width: 16),
                  Text(
                    R.string.chon_trong_thu_vien.tr(),
                    style: TextStyle(
                      color: R.color.color0xff333333,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(context);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
                  const SizedBox(width: 16),
                  Text(
                    R.string.chup_anh.tr(),
                    style: TextStyle(
                      color: R.color.color0xff333333,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(context);
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(R.string.cancel.tr(),
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      //Message.showToastMessage(context, R.string.max_image_select.tr());
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        _cubit.files.add(pickedFile);
        _cubit.refresh();
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    final Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final Widget continueButton = TextButton(
      child: Text(R.string.allowed.tr()),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    final AlertDialog alert = AlertDialog(
      title: Text(R.string.notification.tr()),
      content: Text(R.string.ask_for_permission.tr()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _openCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        _cubit.files.add(pickedFile);

        _cubit.refresh();
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _showDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_earse, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.ban_muon_xoa_du_lieu.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(R.string.confirm_to_remove_data.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _cubit.deleteData(widget.id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(R.string.delete.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _showDialogSave() {
    final note = _controllerNote.text;

    if (_cubit.model != null) {
      final noteText = _cubit.model!.note ?? '';
      final date =
          DateTime.fromMillisecondsSinceEpoch(_cubit.model!.date! * 1000);
      if (note == noteText &&
          _cubit.selectedFoods.length == _cubit.model!.foods.length &&
          _cubit.files.length == _cubit.model!.images.length &&
          _cubit.removeIDs.isEmpty &&
          date.millisecondsSinceEpoch ==
              _cubit.selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty &&
        _cubit.selectedFoods.isEmpty &&
        _cubit.files.isEmpty) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.ban_muon_quay_lai.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(R.string.confirm_to_back.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: R.color.grayBorder),
                                  child: Center(
                                    child: Text(R.string.van_o_lai.tr(),
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
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
                                child: Text(R.string.exit.tr(),
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void dispose() {
    _animtionController.dispose();
    _focusNode.dispose();
    _controllerNote.dispose();
    super.dispose();
  }
}
