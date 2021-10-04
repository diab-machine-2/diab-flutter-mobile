import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/body_parameter/body_parameter.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'kcal_parameter.dart';

typedef NumCallback = Function(num?);

class KcalParameterPage extends StatefulWidget {
  final bool isUpdate;
  final NumCallback? callback;

  const KcalParameterPage({Key? key, this.callback, this.isUpdate = false})
      : super(key: key);

  @override
  _KcalParameterPageState createState() => _KcalParameterPageState();
}

class _KcalParameterPageState extends State<KcalParameterPage> {
  TextEditingController _controller = TextEditingController();
  late KcalParameterCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = KcalParameterCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
          child: SingleChildScrollView(
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
                          Utils.showErrorSnackBar(context, state.error);
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
                  )))),
    );
  }

  Widget buildPage(BuildContext context, KcalParameterState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          R.string.diab_parameter.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: R.color.textDark,
          ),
        ),
        SizedBox(height: 17.h),
        Visibility(
          visible: widget.isUpdate,
          child: Padding(
            padding: EdgeInsets.only(bottom: 17.h),
            child: Text(
              R.string.text_warning_change_param.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: R.color.black,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[-.]'))
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
            // SizedBox(
            //   width: 5.h,
            // ),
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
        SizedBox(height: 25.h),
        Center(
          child: Text(
            R.string.have_3_meal.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: R.color.textDark,
            ),
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
                    showDialog(
                      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                      context: context,
                      builder: (_) => NoticeChangePage(onClick: () {
                        String text = _controller.text;
                        num? number;
                        if (!Utils.isEmpty(text)) {
                          number = num.parse(text);
                        }
                        if (widget.callback != null && number != null)
                          widget.callback!(number);
                        NavigationUtil.pop(context);
                      }),
                    );
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget buildCheckMeal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRowCheck(R.string.no_sub_meal.tr(), 0),
        SizedBox(height: 10.h),
        Container(
          height: 1,
          margin: EdgeInsets.only(left: 10),
          width: 170.h,
          color: R.color.gray,
        ),
        SizedBox(height: 10.h),
        buildRowCheck(R.string.breakfast_meal.tr(), 1),
        buildRowCheck(R.string.lunch_meal.tr(), 2),
        buildRowCheck(R.string.dinner_meal.tr(), 3),
      ],
    );
  }

  Widget buildRowCheck(String title, int index) {
    bool isChecked = _cubit.selectedMeal == index;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: isChecked,
            checkColor: R.color.white,
            activeColor: R.color.accentColor,
            onChanged: (bool? newValue) {
              _cubit.selectOptionMeal(index);
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
