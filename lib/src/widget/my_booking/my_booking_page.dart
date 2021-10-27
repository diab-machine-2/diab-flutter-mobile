import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'my_booking.dart';

class MyBookingPage extends StatefulWidget {
  @override
  _MyBookingPageState createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  late MyBookingCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = MyBookingCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.grey200,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<MyBookingCubit, MyBookingState>(
          listener: (context, state) {
            if (state is MyBookingFailure)
              Message.showToastMessage(context, state.error);
            if (state is MyBookingSuccess) {}
          },
          builder: (context, state) {
            if (state is MyBookingLoading) {
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

  Widget buildPage(BuildContext context, MyBookingState state) {
    return CommonPage(
      background: R.drawable.bg_welcome,
      title: R.string.my_plan.tr(),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 10),
        itemCount: 2,
        itemBuilder: (context, index) {
          return cardWidget(index);
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 16.h,
          );
        },
      ),
    );
  }

  Widget cardWidget(
      int index,
      {String? date,
      String? time,
      String? description,
      String? coachAvatar,
      String? coachName}) {
    return CardWidget(
        backgroundImage: R.drawable.bg_card_my_plan,
        borderColor: R.color.green,
        borderWidth: 0,
        child: Container(
      padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date ?? "Thứ 6, 12/7/2021",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.white,
                    height: 1.4,
                    letterSpacing: 0.4),
              ),
              Text(
                time ?? "10:00 am - 11:00 am",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: R.color.white,
                    height: 1.4,
                    letterSpacing: 0.4),
              ),
              SizedBox(height: 12.h,),
              Text(
                description ?? "Buổi Coaching 1 - 1 lập kế hoạch học tập cho user sử dụng gói thấu cảm",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: R.color.white,
                    height: 1.4,
                    letterSpacing: 0.4),
              ),
              Visibility(
                visible: index % 2 == 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                            imageUrl: "https://www.w3schools.com/howto/img_avatar.png", width: 45.h, height: 45.h,),
                        SizedBox(width: 10.h,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                R.string.coach.tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: R.color.white,
                                    height: 1.4,
                                    letterSpacing: 0.2),
                              ),
                              SizedBox(height: 3.h,),
                              Text(
                                coachName ?? "Coach Name",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.white,
                                    height: 1.4,
                                    letterSpacing: 0.2),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.h,),
                    ButtonWidget(title: R.string.join.tr(),
                        textColor: R.color.white,
                        borderColor: R.color.white,
                        backgroundColor: Colors.transparent,
                        height: 35.h,
                        onPressed: () {}),
                  ],
                ),
              )
            ],

    ),
        ));
  }
}
