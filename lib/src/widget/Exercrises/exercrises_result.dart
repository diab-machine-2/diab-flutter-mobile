import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:medical/src/widget/Exercrises/widget/circular_arch_progress_bar.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ai_suggestion.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'dart:math' as math;

import 'package:medical/src/widgets/network_image_widget.dart';

class ExercisesResult extends StatefulWidget {
  final int periodFilterType;

  const ExercisesResult({
    Key? key,
    this.periodFilterType = 0,
  }) : super(key: key);

  @override
  _ExercisesResultState createState() => _ExercisesResultState();
}

class _ExercisesResultState extends State<ExercisesResult>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  late int periodFilterType;

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.periodFilterType;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: R.color.backgroundColorNew,
            appBar: AppBar(
              leading: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.white),
                  onPressed: _goBack),
              title: Transform(
                transform: Matrix4.translationValues(-20, 0.0, 0.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    R.string.exercrise_result_title.tr(),
                    style: TextStyle(
                        color: R.color.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              backgroundColor: R.color.transparent, //No more green
              elevation: 0.0, //Shadow gone
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      R.color.greenGradientMid,
                      R.color.greenGradientBottom
                    ])),
              ),
            ),
            body: Container(width: double.infinity, child: _buildContainer())),
      ),
    );
  }

  Widget _buildContainer() {
// = screen width / 4 - 16;
    final containerSize = (1.sw - 16.w * 4) / 4;
    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              _buildProgressSection(),

              // Suggestion Section
              _buildSuggestionSection(),

              // Nút "Thêm vận động"
              SizedBox(
                // height: 16.h,
                width: double.infinity,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                  child: ButtonWidget(
                    title: R.string.them_hoat_dong.tr(),
                    backgroundColor: R.color.white,
                    textSize: 14,
                    borderColor: R.color.greenGradientBottom,
                    textColor: R.color.greenGradientBottom,
                    wIcon: Icon(
                      Icons.add_circle_outline,
                      color: R.color.greenGradientBottom,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, NavigatorName.exercrise_add_v2);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              // Activity List
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildActivityList(),
              ),

              SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: KeyboardVisibilityProvider(
              child: KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isKeyboardVisible ? 0 : 60,
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: R.color.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ButtonWidget(
                                title: R.string.cancel.tr(),
                                backgroundColor: R.color.white,
                                borderColor: R.color.greenGradientBottom,
                                textColor: R.color.textDark,
                                onPressed: () {
                                  _goBack();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              flex: 1,
                              child: ButtonWidget(
                                title: R.string.confirm.tr(),
                                backgroundColor: R.color.greenGradientMid,
                                textColor: R.color.white,
                                onPressed: () {
                                  Message.showToastMessage(
                                      context, 'Confirm button pressed');
                                },
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ),
            ))
      ],
    );
  }

  Widget _buildProgressSection() {
    final containerSize =
        MediaQuery.of(context).size.width * 0.65; // Kích thước vòng cung
    return Container(
      padding: EdgeInsets.all(24.w),
      color: R.color.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề với RichText
          Padding(
            padding: EdgeInsets.all(4.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bạn hoàn thành ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                    ),
                  ),
                  TextSpan(
                    text: '15/45 phút',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  TextSpan(
                    text: ' mục tiêu!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Circular Progress
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularArchProgressBar(
                  value: 33.33, // Giá trị phần trăm (15/45 phút)
                  strokeWidth: 28,
                  fillColor: R.color.greenGradientBottom,
                  backgroundColor: R.color.textDark.withOpacity(0.1),
                  width: containerSize,
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '15',
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: 'sfpro',
                          fontWeight: FontWeight.bold,
                          color: R.color.textDark,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Baseline(
                        baseline: -14
                            .sp, // Điều chỉnh baseline để đưa chữ "Phút" lên cao
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          'Phút',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'sfpro',
                            color: R.color.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Calories Info
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Calories:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: R.color.yellow,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '100/800 Kcal',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: R.color.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Progress Bar for Calories
          Container(
            height: 12.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: R.color.textDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 100 / 800, // Tỷ lệ calories (100/800)
              child: Container(
                decoration: BoxDecoration(
                  color: R.color.yellow,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: R.color.backgroundColorNew,
      child: ExercrisesAISuggestion(
        periodFilterType: periodFilterType,
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'name': 'Đi bộ',
        'time': '08:00',
        'duration': '15 Phút',
        'calories': '100 Kcal'
      },
      {
        'name': 'Bơi lội',
        'time': '14:00',
        'duration': '30 Phút',
        'calories': '400 Kcal'
      },
      {
        'name': 'Bơi lội',
        'time': '16:00',
        'duration': '15 Phút',
        'calories': '250 Kcal'
      },
    ];

    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: NetWorkImageWidget(
                  imageUrl: 'https://example.com/image.jpg',
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          activity['name']!,
                          style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.fiber_manual_record,
                              size: 10, color: R.color.primaryGreyColor),
                        ),
                        Text(
                          '${activity['time']}',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: R.color.textDark,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${activity['duration']}   |   ${activity['calories']}',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, NavigatorName.exercrise_add_v2);
                },
                child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: R.color.greenGradientBottom
                          .withOpacity(0.1), // Màu nền
                      borderRadius: BorderRadius.circular(24.r), // Làm tròn
                    ),
                    child:
                        Icon(Icons.edit, size: 16.w, color: R.color.textDark)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: R.color.white,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle share action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: R.color.white,
                side: BorderSide(color: R.color.greenGradientBottom),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Chia sẻ',
                style: TextStyle(
                    fontSize: 14.sp, color: R.color.greenGradientBottom),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle complete action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: R.color.greenGradientBottom,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Hoàn tất',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
