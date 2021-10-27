import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';

import 'booking_coach.dart';

class BookingCoachPage extends StatefulWidget {

  @override
  _BookingCoachPageState createState() => _BookingCoachPageState();
}

class _BookingCoachPageState extends State<BookingCoachPage> {
  TextEditingController _dateController = TextEditingController();
  late BookingCoachCubit _cubit;
  bool isBooked = true;
  final List<String> listTime = [
    R.string.time_9_10.tr(),
    R.string.time_10_11.tr(),
    R.string.time_11_12.tr(),
    R.string.time_12_13.tr(),
    R.string.time_13_14.tr(),
    R.string.time_14_15.tr(),
    R.string.time_15_16.tr(),
    R.string.time_16_17.tr(),
    R.string.time_17_18.tr(),
    R.string.time_18_19.tr(),
    R.string.time_19_20.tr(),
    R.string.time_20_21.tr(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = BookingCoachCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.grey200,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<BookingCoachCubit, BookingCoachState>(
          listener: (context, state) {
            if (state is BookingCoachFailure)
              Message.showToastMessage(context, state.error);
            if (state is BookingCoachSuccess) {}
            if (state is SelectedDateSuccess)
              _dateController.text = DateUtil.parseDateToString(
                  _cubit.selectedDate, Const.FULL_DATE_FORMAT, locale: Const.VI);
          },
          builder: (context, state) {
            if (state is BookingCoachLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, BookingCoachState state) {
    return CommonPage(
      background: R.drawable.bg_welcome,
      title: R.string.book_coach.tr(),
      child: isBooked == true ? seeBookingWidget() : bookCoachWidget(),
    );
  }

  Widget bookCoachWidget() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.h),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      R.string.description_book_coach.tr(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                          height: 1.4,
                          letterSpacing: 0.4),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Image.asset(R.drawable.img_book_coach, height: 120.h),
                ],
              ),
              SizedBox(height: 25.h),
              Text(
                R.string.date_book.tr(),
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.textDark,
                    height: 1.4,
                    letterSpacing: 0.4),
              ),
              SizedBox(height: 12.h),
              TextFieldWidget(
                  autoFocus: false,
                  controller: _dateController,
                  padding:
                  EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.h),
                  readOnly: true,
                  isRequired: true,
                  // will disable paste operation
                  onTap: pickDate,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  suffixIcon: GestureDetector(
                    onTap: pickDate,
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: R.color.gray,
                      size: 20.h,
                    ),
                  )),
              SizedBox(height: 25.h),
              Text(
                R.string.time_book.tr(),
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.textDark,
                    height: 1.4,
                    letterSpacing: 0.4),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.h,
                runSpacing: 20.h,
                children: listTime.map((e) {
                  bool isSelected = e == _cubit.selectedTime;
                  return InkWell(
                    onTap: () {
                      _cubit.pickTime(e);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.h, vertical: 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.h),
                        color: isSelected
                            ? R.color.color0xffB1DDDB
                            : R.color.white,
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? R.color.accentColor
                                : R.color.grey_2),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
        Container(
            width: 150.w,
            margin: EdgeInsets.only(bottom: 20.h),
            child: ButtonWidget(
                title: R.string.save_booking.tr(),
                onPressed: () {
                  showResultBookingPopup();
                })),
      ],
    );
  }

  Widget seeBookingWidget() {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Image.asset(
          R.drawable.img_result_booking,
          height: 240.h,
        ),
        SizedBox(height: 50.h),
        Text(
          R.string.you_book_coach_success.tr(),
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
              height: 1.4,
              letterSpacing: 0.4),
        ),
        SizedBox(height: 30.h),
        Center(
          child: Container(
            width: 120.w,
            child: ButtonWidget(
              height: 35.h,
              title: R.string.see_booking.tr(),
              textSize: 14.sp,
              onPressed: () {

              },
              backgroundColor: Colors.transparent,
              borderColor: R.color.accentColor,
              textColor: R.color.accentColor,
            ),
          ),
        )
      ],
    );
  }

  void pickDate() {
    DatePicker.showDatePicker(context,
        maxTime: DateTime.now(),
        showTitleActions: true,
        locale: LocaleType.vi,
        currentTime: _cubit.selectedDate, onConfirm: (date) {
      _cubit.pickDate(date);
    });
  }

  void showResultBookingPopup() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.h),
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.h),
              color: R.color.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40.h,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => NavigationUtil.pop(context),
                        child: Icon(
                          Icons.close,
                          color: R.color.textDark,
                          size: 20.h,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    R.drawable.img_result_booking,
                    height: 160.h,
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    R.string.booking_success.tr(),
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
