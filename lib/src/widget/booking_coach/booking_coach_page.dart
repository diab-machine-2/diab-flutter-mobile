import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_calendar_widget.dart';

import 'booking_coach.dart';

class BookingCoachPage extends StatefulWidget {
  @override
  _BookingCoachPageState createState() => _BookingCoachPageState();
}

class _BookingCoachPageState extends State<BookingCoachPage> {
  late BookingCoachCubit _cubit;
  bool isBooked = false;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    final AppRepository repository = AppRepository();
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
                  _cubit.selectedDate, Const.FULL_DATE_FORMAT,
                  locale: Const.VI);
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    R.string.description_book_coach.tr(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark,
                        height: 1.4,
                        letterSpacing: 0.4),
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(R.drawable.img_book_coach, height: 120.h),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              R.string.date_book.tr(),
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark,
                  height: 1.4,
                  letterSpacing: 0.4),
            ),
            const SizedBox(height: 12),
            CustomCalendarWidget(time: DateTime.now()),
            const SizedBox(height: 25),
            Text(
              R.string.time_book.tr(),
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark,
                  height: 1.4,
                  letterSpacing: 0.4),
            ),
            const SizedBox(height: 6),
            Text(
              R.string.select_time_booking_description.tr(),
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  children: [
                    _buildSelectTime(
                      hour: '09',
                      minute: '30',
                      color: R.color.white,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 36,
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              menuMaxHeight: 300,
                              items: <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Container(
                                      width: 22, height: 24, child: Text(value)),
                                );
                              }).toList(),
                              onChanged: (_) {},
                              icon: const SizedBox(),
                              underline: const SizedBox(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          height: 36,
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              menuMaxHeight: 500,
                              items: <String>['E', 'F', 'G', 'H']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (_) {},
                              icon: const SizedBox(),
                              underline: const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 16,
                  height: 1,
                  color: R.color.greenGradientBottom,
                ),
                _buildSelectTime(
                  hour: '10',
                  minute: '30',
                  color: R.color.color0xfff5f5f5,
                ),
              ],
            ),
            const SizedBox(height: 44),
            SafeArea(
              top: false,
              child: Center(
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ButtonWidget(
                    title: R.string.submit_booking.tr(),
                    onPressed: () {
                      showResultBookingPopup();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectTime({
    required String hour,
    required String minute,
    required Color color,
  }) {
    return Container(
      width: 86,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: Text(
              hour,
              style: TextStyle(
                color: R.color.greenGradientBottom,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
            child: Text(
              minute,
              style: TextStyle(
                color: R.color.greenGradientBottom,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
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
              onPressed: () {},
              backgroundColor: Colors.transparent,
              borderColor: R.color.accentColor,
              textColor: R.color.accentColor,
            ),
          ),
        )
      ],
    );
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
