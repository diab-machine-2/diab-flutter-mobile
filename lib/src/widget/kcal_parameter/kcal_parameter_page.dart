import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/body_parameter/body_parameter.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'kcal_parameter.dart';

class KcalParameterPage extends StatefulWidget {
  final bool isUpdate;
  final Function(CreateMenuRequest request)? callback;

  const KcalParameterPage({Key? key, this.callback, this.isUpdate = false})
      : super(key: key);

  @override
  _KcalParameterPageState createState() => _KcalParameterPageState();
}

class _KcalParameterPageState extends State<KcalParameterPage> {
  final TextEditingController _controller = TextEditingController();
  late KcalParameterCubit _cubit;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = KcalParameterCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
          child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 24.h),
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.h),
                color: R.color.white,
              ),
              child: BlocProvider(
                create: (context) => _cubit,
                child: BlocConsumer<KcalParameterCubit, KcalParameterState>(
                  listener: (context, state) {
                    if (state is KcalParameterFailure) {
                      Message.showToastMessage(context, state.error);
                    }
                    if (state is KcalParameterLoading) {
                      BotToast.showLoading();
                    } else {
                      BotToast.closeAllLoading();
                    }
                  },
                  builder: (
                    BuildContext context,
                    KcalParameterState state,
                  ) {
                    return buildPage(context, state);
                  },
                ),
              ))),
    );
  }

  Widget buildPage(BuildContext context, KcalParameterState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              R.string.diab_parameter.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 17.h),
          Text(
            R.string.energy_use_per_day.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  width: 150.h,
                  child: CupertinoTextField(
                    controller: _controller,
                    decoration: BoxDecoration(color: R.color.white),
                    textAlign: TextAlign.center,
                    enableInteractiveSelection: false,
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                    placeholder: '--',
                    placeholderStyle: TextStyle(
                        color: R.color.textDark,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      // setState(() {
                      //   selectedCalo = (value == null ||
                      //       value.isEmpty)
                      //       ? 0
                      //       : int.parse(value);
                      // });
                    },
                  ),
                ),
                Container(height: 1, width: 130.h, color: R.color.gray)
              ]),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(R.string.kcal.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: R.color.textDark,
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => BodyParameterPage(callback: (number) {
                  _controller.text = (number?.round() ?? "--").toString();
                }),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  R.string.recipe.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.accentColor,
                  ),
                ),
                SizedBox(
                  width: 5.h,
                ),
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 20.h,
                  color: R.color.accentColor,
                )
              ],
            ),
          ),
          Visibility(
            visible: widget.isUpdate,
            child: Padding(
              padding: EdgeInsets.only(top: 17.h),
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(68.w, 8.h, 12.w, 8.h),
                    decoration: BoxDecoration(
                      color: R.color.main_6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: R.string.text_if.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: R.color.black,
                          ),
                          children: [
                            TextSpan(
                              text: ' ${R.string.increase.tr()} ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: R.string.text_or.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: ' ${R.string.decrease.tr()} ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: R.string.text_warning_change_param.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: R.color.black,
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Image.asset(
                    R.drawable.img_gym_trainer,
                    width: 64.w,
                    height: 82.h,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            R.string.have_3_meal.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 17.h),
          Padding(
            padding: EdgeInsets.only(left: 40.h),
            child: buildCheckMeal(),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: ButtonWidget(
                    title: R.string.cancel.tr(),
                    backgroundColor: R.color.grayBorder,
                    textColor: R.color.textDark,
                    height: 43.h,
                    onPressed: () => NavigationUtil.pop(context),
                  )),
              SizedBox(width: 15.w),
              Expanded(
                  flex: 1,
                  child: ButtonWidget(
                    title: R.string.agree.tr(),
                    height: 43.h,
                    onPressed: () {
                      final String text = _controller.text.trim();
                      int? number;
                      if (!Utils.isEmpty(text)) {
                        number = int.parse(text);
                        showDialog(
                          barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                          context: context,
                          builder: (_) => NoticeChangePage(onClick: () {
                            NavigationUtil.pop(context);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (widget.callback != null && number != null) {
                                _cubit.createMenuRequest.setKcal = number;
                                widget.callback!(_cubit.createMenuRequest);
                              }
                            });
                          }),
                        );
                      } else {
                        Message.showToastMessage(
                            context, R.string.ban_chua_nhap_gia_tri.tr());
                      }
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCheckMeal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRowCheck(
            title: R.string.no_sub_meal.tr(),
            isChecked: _cubit.isNoSubMeal,
            onChecked: (isChecked) {
              if (isChecked == true) {
                _cubit.onCheckedNoSubMeal();
              }
            }),
        SizedBox(height: 10.h),
        Container(
          height: 1,
          margin: const EdgeInsets.only(left: 10),
          width: 170.h,
          color: R.color.gray,
        ),
        SizedBox(height: 10.h),
        buildRowCheck(
            title: R.string.breakfast_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeBreakfast,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeBreakfast = isChecked;
              _cubit.refresh();
            }),
        buildRowCheck(
            title: R.string.lunch_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeLunch,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeLunch = isChecked;
              _cubit.refresh();
            }),
        buildRowCheck(
            title: R.string.dinner_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeDinner,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeDinner = isChecked;
              _cubit.refresh();
            }),
      ],
    );
  }

  Widget buildRowCheck({
    required String title,
    required bool? isChecked,
    required Function(bool isSelected) onChecked,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: isChecked ?? false,
            checkColor: R.color.white,
            activeColor: R.color.accentColor,
            onChanged: (isChecked) {
              onChecked(isChecked ?? false);
            },
          ),
        ),
        SizedBox(width: 22.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: R.color.textDark,
          ),
        ),
      ],
    );
  }
}
