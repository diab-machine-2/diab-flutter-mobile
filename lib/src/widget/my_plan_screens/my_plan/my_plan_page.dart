import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/dashed_vertical_line.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../lesson_detail/lesson_detail.dart';
import 'models/lesson_type.dart';
import 'models/plan_type.dart';
import 'my_plan.dart';

class MyPlanPage extends StatefulWidget {
  const MyPlanPage();

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  late final MyPlanCubit _cubit;
  final PageController _pageController = PageController(initialPage: 1);
  final RefreshController _controller = RefreshController();

  @override
  void initState() {
    final AppRepository appRepository = AppRepository();
    _cubit = MyPlanCubit(appRepository);
    _cubit.getInitData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<MyPlanCubit, MyPlanState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is MyPlanLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              _controller.refreshCompleted();
            }
            if (state is MyPlanFailure) {
              Message.showToastMessage(context, state.error);
            }
            return BackgroundPage(
              background: R.drawable.bg_welcome,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 24.h),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      border: Border.all(color: R.color.color0xfff5f5f5),
                      boxShadow: [
                        BoxShadow(
                          color: R.color.greenGradientBottom.withOpacity(0.08),
                          spreadRadius: 5,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 18.h, horizontal: 16.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => NavigationUtil.pop(context),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.h),
                                    child: Icon(
                                      CupertinoIcons.arrow_left,
                                      color: R.color.textDark,
                                      size: 28.h,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    R.string.activity.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        color: R.color.textDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CustomMultiSelectToggle(
                              toggleList: _cubit.planTypeList
                                  .map((e) => e.title)
                                  .toList(),
                              selectedIndex: _cubit.currentPlanTypeIndex,
                              onChange: (index) {
                                _cubit.changePlanType(index);
                                _pageController.jumpToPage(index);
                              },
                            ),
                          ),
                          _buildScheduleWidget(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      controller: _controller,
                      onRefresh: () => _cubit.getInitData(isRefresh: true),
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Container(),
                          _buildLessonTab(),
                          Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLessonTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 20.h,
            horizontal: 16.w,
          ),
          width: 159.w,
          height: 32.h,
          child: ButtonWidget(
            title: R.string.search_by_key.tr(),
            onPressed: () {
              _showSearchDialog();
            },
            textSize: 14,
            radius: 8,
          ),
        ),
        Container(
          height: 30.h,
          child: Row(
            children: List.generate(
              _cubit.lessonTypeList.length,
              (index) {
                return _buildLessonTypeSelect(
                    title: _cubit.lessonTypeList[index].title,
                    isActive: _cubit.currentLessonTypeIndex == index,
                    onTap: () {
                      _cubit.changeLessonType(index);
                    });
              },
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Visibility(
                    visible: _cubit.currentLessonType == LessonType.route,
                    child: Positioned(
                      top: (127.h) / 2 + 20.h,
                      left: 19.5.w,
                      child: Container(
                        height: max((_cubit.lessonsList.length - 1) * 127.h, 0),
                        width: 1,
                        child: const DashedVerticalLine(),
                      ),
                    ),
                  ),
                  Column(
                    children: List.generate(
                      _cubit.lessonsList.length,
                      (index) => _buildLessonWidget(
                          lessonDetail: _cubit.lessonsList[index],
                          onTap: () {
                            if (_cubit.lessonsList[index]?.id?.isNotEmpty ==
                                true) {
                              NavigationUtil.navigatePage(
                                context,
                                LessonDetailPage(
                                  _cubit.lessonsList[index]!.id!,
                                ),
                              );
                            }
                          }),
                    )
                      ..insert(0, SizedBox(height: 20.h))
                      ..add(SizedBox(height: 20.h)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonWidget({
    required MyLessonResponseData? lessonDetail,
    VoidCallback? onTap,
  }) {
    final bool isLocked =
        lessonDetail?.learningStatus == Const.LESSON_NOT_LEARN &&
            _cubit.currentLessonType == LessonType.route;
    return Container(
      margin: EdgeInsets.symmetric(vertical: (127.h - 87.w) / 2),
      height: 87.w,
      alignment: Alignment.center,
      color: R.color.transparent,
      child: Row(
        children: [
          Visibility(
            visible: _cubit.currentLessonType == LessonType.route,
            child: Container(
              margin: EdgeInsets.only(left: 12.w),
              width: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R.color.white,
                border: Border.all(
                  width: 4.w,
                  color: getBorderColor(lessonDetail?.learningStatus),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: InkWell(
              onTap: isLocked
                  ? () {
                      _showLockedDialog();
                    }
                  : onTap,
              child: Row(
                children: [
                  Container(
                    height: 87.w,
                    width: 87.w,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lessonDetail?.module ?? '',
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            lessonDetail?.name ?? '',
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildLessonStatusWidget(lessonDetail: lessonDetail),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24.w,
                    color: R.color.greenGradientBottom,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildLessonStatusWidget(
      {required MyLessonResponseData? lessonDetail}) {
    if (lessonDetail?.learningStatus == Const.LESSON_LEARNT) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 20.w,
            color: R.color.greenGradientBottom,
          ),
          SizedBox(width: 8.w),
          Text(
            'Hoàn thành',
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    if (lessonDetail?.learningStatus == Const.LESSON_LEARNING) {
      final int progress = lessonDetail?.percentComplete ?? 0;
      return Row(
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 2,
                backgroundColor: R.color.grayBorder,
                valueColor:
                    AlwaysStoppedAnimation<Color>(R.color.greenGradientBottom),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$progress%',
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    if (lessonDetail?.learningStatus == Const.LESSON_NOT_LEARN) {
      if (_cubit.currentLessonType == LessonType.route) {
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: Image.asset(R.drawable.ic_lesson_lock),
            ),
            const SizedBox(width: 8),
            Text(
              'Chưa mở khoá',
              style: TextStyle(
                color: R.color.captionColorGray,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }
      if (_cubit.currentLessonType == LessonType.suggest) {
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: Image.asset(R.drawable.ic_lesson_not_learn),
            ),
            const SizedBox(width: 8),
            Text(
              'Chưa học',
              style: TextStyle(
                color: R.color.captionColorGray,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  Color getBorderColor(int? learningStatus) {
    if (learningStatus == Const.LESSON_LEARNT)
      return R.color.greenGradientBottom;
    if (learningStatus == Const.LESSON_LEARNING) return R.color.color0xff50C087;
    return R.color.color0xffC0C2C5;
  }

  Widget _buildLessonTypeSelect({
    required String title,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? R.color.greenGradientBottom
                    : R.color.captionColorGray,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isActive)
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: R.color.greenGradientBottom,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              )
            else
              Container(
                height: 1.h,
                color: R.color.captionColorGray,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleWidget() {
    if (_cubit.timeData == null) return const SizedBox();
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _cubit.timeData!.weekList.length,
                (index) => _buildSingleWeek(
                    weekIndex: index,
                    isSelected: index == _cubit.timeData?.currentWeekIndex,
                    onSelect: () {
                      _cubit.onSelectWeek(index);
                    }),
              )..add(const SizedBox(width: 16)),
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (index) => _buildSingleDay(
                  day: _cubit.timeData?.currentWeek[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleWeek({
    required int weekIndex,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(left: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? R.color.blue_6 : R.color.transparent,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Text(
          'Tuần ${weekIndex + 1}',
          style: TextStyle(
            color: isSelected
                ? R.color.greenGradientBottom
                : R.color.captionColorGray,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSingleDay({required DateTime? day}) {
    if (day == null) return const SizedBox();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: R.color.greenGradientBottom,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.w),
            child: Column(
              children: [
                Text(
                  'T${day.weekday + 1}',
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 1.h,
                  width: 16.w,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
          Text(
            'T.${day.month}',
            style: TextStyle(
              color: R.color.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              child: Container(
                width: 344.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 10.h,
                        children: List.generate(
                          _cubit.keyWordList.length,
                          (index) => GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                border:
                                    Border.all(color: R.color.color0xffB1DDDB),
                              ),
                              child: Text(
                                _cubit.keyWordList[index],
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150.w,
                          child: ButtonWidget(
                            height: 43.h,
                            title: 'Huỷ',
                            onPressed: () {
                              NavigationUtil.pop(context);
                            },
                            textColor: R.color.textDark,
                            backgroundColor: R.color.grayBorder,
                          ),
                        ),
                        SizedBox(
                          width: 150.w,
                          child: ButtonWidget(
                              height: 43.h,
                              title: 'Xác nhận',
                              onPressed: () {
                                NavigationUtil.pop(context);
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              child: Container(
                width: 344.w,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Image.asset(R.drawable.img_lesson_locked,
                          width: 175.w, height: 180.h),
                    ),
                    Text(
                      'Bài học chưa mở khoá!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    Text(
                      'Bạn cần học lần lượt các bài học theo lộ trình của diaB để mở khoá bài học này.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24.h),
                      padding: EdgeInsets.symmetric(horizontal: 50.w),
                      child: ButtonWidget(
                        height: 32.h,
                        title: 'Đồng ý',
                        onPressed: () {},
                        textSize: 14.sp,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
