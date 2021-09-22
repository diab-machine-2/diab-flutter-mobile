import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'detail_package.dart';

class DetailPackagePage extends StatefulWidget {
  const DetailPackagePage({Key? key}) : super(key: key);

  @override
  _DetailPackagePageState createState() => _DetailPackagePageState();
}

class _DetailPackagePageState extends State<DetailPackagePage> {
  late DetailPackageCubit _cubit;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = DetailPackageCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<DetailPackageCubit, DetailPackageState>(
          listener: (context, state) {
            if (state is DetailPackageFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            DetailPackageState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, DetailPackageState state) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(R.drawable.bg_home), fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.only(top: 200),
                width: 128.w,
                child: ButtonWidget(
                  title: R.string.interest.tr(),
                  onPressed: () {
                    showModelSheet(context);
                  },
                  backgroundColor: R.color.white,
                  borderColor: R.color.accentColor,
                  textColor: R.color.accentColor,
                ))
          ],
        ),
      ),
    );
  }

  void showModelSheet(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider<DetailPackageCubit>.value(
          value: _cubit,
          child: BlocBuilder<DetailPackageCubit, DetailPackageState>(builder: (
            BuildContext context,
            DetailPackageState state,
          ) {
            return SingleChildScrollView(
              child: Container(
                color: R.color.white,
                child: Column(
                  children: [
                    Container(
                      decoration:
                          BoxDecoration(color: R.color.white, boxShadow: [
                        BoxShadow(
                          color: R.color.accentColor.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 23.h, horizontal: 31.h),
                        color: R.color.white,
                        child: Text(
                          R.string.interest_course.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    rowOptionWidget(R.string.option_already_register.tr(), 0),
                    rowOptionWidget(R.string.option_need_more_info.tr(), 1),
                    rowOptionWidget(R.string.option_another.tr(), 2),
                    sendMessageWidget(),
                    Container(
                      margin:
                          EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
                      child: ButtonWidget(
                        title: R.string.send.tr(),
                        textColor: _cubit.selectedIndex == null
                            ? R.color.gray
                            : R.color.white,
                        onPressed: _cubit.selectedIndex == null ? null : () {
                          NavigationUtil.pop(context);
                        },
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          })),
    );
  }

  Widget sendMessageWidget() {
    return Visibility(
      visible: _cubit.selectedIndex == 2,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
        child: TextFieldWidget(
          controller: _controller,
          padding: EdgeInsets.all(16.h),
          maxLines: 5,
          hintText: R.string.hint_msg_to_diab.tr(),
          textInputAction: TextInputAction.send,
          onSubmitted: (text) {
            NavigationUtil.pop(context);
          },
        ),
      ),
    );
  }

  Widget rowOptionWidget(String title, int index) {
    bool isSelected = index == _cubit.selectedIndex;
    return GestureDetector(
      onTap: () => _cubit.selectOption(index),
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.h),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: isSelected
                    ? R.color.accentColor
                    : R.color.grayComponentBorder,
                width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? R.color.accentColor : R.color.textDark,
              fontSize: 16.sp),
        ),
      ),
    );
  }
}
