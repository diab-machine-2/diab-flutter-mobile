import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/BloodSugar/add_bloodSugar.dart';
import 'package:medical/src/widget/Food/widget/time_frame_food.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/food_menu_screens/change_menu/change_menu.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:permission_handler/permission_handler.dart';

import '../search_food_controller.dart';
import 'daily_nutrition.dart';

class DailyNutritionPage extends StatefulWidget {
  const DailyNutritionPage({required this.type, required this.id});

  final String? type;
  final String? id;

  @override
  _DailyNutritionPageState createState() => _DailyNutritionPageState();
}

class _DailyNutritionPageState extends State<DailyNutritionPage> {
  late final DailyNutritionCubit _cubit;

  final TextEditingController _controllerNote = TextEditingController();

  @override
  void initState() {
    final AppRepository appRepository = AppRepository();
    _cubit = DailyNutritionCubit(appRepository);
    _cubit.getInitialData(type: widget.type, id: widget.id);
    super.initState();
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
                    onTap: () {
                      _cubit.showDetailToggle();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          children: [
                            SizedBox(height: 16.h),
                            Visibility(
                              visible: _cubit.showDetail,
                              child: Description(
                                  input: true,
                                  data: _cubit.des,
                                  titleDetail: R
                                      .string.che_do_dinh_duong_benh_tieu_duong
                                      .tr()),
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: Container(
                                    height: 136.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: R.color.color0xffF4DBBD,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 16.w),
                                    Image.asset(R.drawable.img_food_person,
                                        width: 113.w, height: 148.h),
                                    SizedBox(width: 16.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${R.string.luong_calo_ban_da_nap.tr()}:'),
                                        SizedBox(height: 8.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatNumber(_cubit.totalKcal),
                                              style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 3.h),
                                              child: Text(
                                                R.string.kcal.tr(),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
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
                                                width: 24.w, height: 24.h),
                                            SizedBox(width: 8.w),
                                            Text(
                                                convertToUTC(
                                                    _cubit.selectedDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    'HH:mm - dd/MM/yyyy'),
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ]),
                                      SizedBox(height: 16.h),
                                      Container(
                                          height: 1,
                                          color: R.color.color0xffE5E5E5),
                                      SizedBox(height: 8.h),
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
                                              width: 24.w, height: 24.h),
                                          SizedBox(width: 8.w),
                                          Text(
                                            _cubit.selectedTimeFrame == null
                                                ? R.string.chon_khung_gio.tr()
                                                : _cubit
                                                    .selectedTimeFrame!.name ?? '',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Container(
                                          height: 1,
                                          color: R.color.color0xffE5E5E5),
                                      SizedBox(height: 8.h),
                                    ]),
                                  ),
                                )
                              ]),
                            ),
                            _buildItemLayout(
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    addFood(context);
                                  },
                                  child: Container(
                                    color: R.color.transparent,
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Image.asset(R.drawable.ic_bowl,
                                                width: 24, height: 24),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  R.drawable.ic_circle_plus_exe,
                                                  width: 24,
                                                  height: 24,
                                                ),
                                                SizedBox(width: 4.h),
                                                Text(
                                                  R.string.them_mon_an.tr(),
                                                  style: TextStyle(
                                                    color: R.color.mainColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                      SizedBox(height: 16.h),
                                      Container(
                                          height: 1,
                                          color: R.color.color0xffE5E5E5),
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
                                                color: R.color.color0xffD6D8E0);
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                                final String quantity = '${roundAsFixed(_cubit.selectedFoods[index].portion)}';
                                                final String kcal = formatNumber(_cubit.selectedFoods[index].portion * _cubit.selectedFoods[index].calorie!);
                                                final String detail = '${R.string.da_an.tr()} $quantity ${_cubit.selectedFoods[index].unit}, $kcal ${R.string.kcal.tr()}';
                                            return Container(
                                              color: R.color.transparent,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                              ),
                                              child: Row(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: _cubit
                                                            .selectedFoods[
                                                                index]
                                                            .image!
                                                            .url ??
                                                        '',
                                                    width: 50,
                                                    height: 50,
                                                    placeholder: (_, __) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    },
                                                    errorWidget: (_, __, ___) {
                                                      return Image.asset(R
                                                          .drawable
                                                          .ic_food_default);
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.w),
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
                                                                  color: R.color
                                                                      .textDark,
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)),
                                                          SizedBox(height: 4.h),
                                                          Text(
                                                            detail,
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .textDark,
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final dynamic result =
                                                          await NavigationUtil
                                                              .navigatePage(
                                                        context,
                                                        ChangeMenuPage(
                                                          preFoodModel: _cubit
                                                                  .selectedFoods[
                                                              index],
                                                          hasSelectQuantity:
                                                              true,
                                                        ),
                                                      );
                                                      if (result is FoodModel) {
                                                        _cubit.selectedFoods[
                                                            index] = result;
                                                        _cubit.calculatorCalo();
                                                        _cubit.refresh();
                                                      }
                                                    },
                                                    child: Image.asset(
                                                      R.drawable.ic_refresh,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.w),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _cubit.selectedFoods
                                                          .removeAt(index);
                                                      _cubit.calculatorCalo();
                                                      _cubit.refresh();
                                                    },
                                                    child: Image.asset(
                                                      R.drawable.ic_trash_red,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                    ]),
                                  ),
                                )
                              ]),
                            ),
                            _buildItemLayout(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_note_text,
                                        width: 24, height: 24),
                                    SizedBox(width: 8.w),
                                    Text(
                                      R.string.ghi_chu.tr(),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ]),
                                  SizedBox(height: 24.h),
                                  TextField(
                                      controller: _controllerNote,
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: R
                                              .string.nhap_ghi_chu_cua_ban
                                              .tr(),
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8.h),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  R.color.primaryGreyColor))),
                                  Container(
                                      height: 1,
                                      color: R.color.color0xffE5E5E5),
                                  SizedBox(height: 8.h),
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
                                            ? Image.asset(
                                                R.drawable.ic_add_photo)
                                            : Stack(
                                                alignment:
                                                    AlignmentDirectional.topEnd,
                                                children: [
                                                  Positioned.fill(
                                                      child: _cubit.files[index]
                                                              is PickedFile
                                                          ? Image.file(
                                                              File(_cubit
                                                                  .files[index]
                                                                  .path),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CachedNetworkImage(
                                                              imageUrl: _cubit
                                                                  .files[index]
                                                                  .url,
                                                              fit: BoxFit
                                                                  .cover)),
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
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
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
                              height: 48.h,
                              width: 195.w,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.h),
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
                                      fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SafeArea(
                          top: false,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showDialogDelete(context);
                                  },
                                  child: Container(
                                      height: 48.h,
                                      width: 164.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          border: Border.all(
                                              color: R.color.red, width: 2.w)),
                                      child: Center(
                                        child: Text(R.string.xoa_du_lieu.tr(),
                                            style: TextStyle(
                                                color: R.color.red,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    _cubit.editData(widget.id);
                                  },
                                  child: Container(
                                    height: 48.h,
                                    width: 164.w,
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
                                              fontSize: 16.sp,
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

  Widget _buildItemLayout({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
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
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                  SizedBox(width: 16.w),
                  Text(
                    R.string.chon_trong_thu_vien.tr(),
                    style: TextStyle(
                      color: R.color.color0xff333333,
                      fontSize: 14.sp,
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
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16.w),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(R.string.confirm_to_remove_data.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43.h,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _cubit.deleteData(widget.id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43.h,
                                  decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(R.string.delete.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(R.string.confirm_to_back.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400)),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                  height: 43.h,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: R.color.grayBorder),
                                  child: Center(
                                    child: Text(R.string.van_o_lai.tr(),
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600)),
                                  ))),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43.h,
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
                                        fontSize: 16.sp,
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
}
