import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../activity_tab/activity_tab.dart';
import '../lesson_tab/lesson_tab.dart';
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
                    color: R.color.white,
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
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    R.string.activity.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
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
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(),
                        const LessonTabPage(),
                        const ActivityTabPage(),
                      ],
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

  Widget _buildFilterWidget() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: Container(),
          ),
          Row(children: [
            Text(
              'Lọc lịch trình',
              style: TextStyle(
                color: R.color.greenGradientBottom,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ]),
        Container(),
      ],
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    7,
                    (index) => Container(
                      alignment: Alignment.bottomCenter,
                      width: 16.sp + 8.w,
                      child: Text(
                        _cubit.timeData?.currentWeek.dayList[index].dayInWeek ??
                            '',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(
                    13,
                    (index) {
                      return index.isOdd
                          ? Expanded(
                              child: Container(
                                height: 1,
                                color: index ~/ 2 >= 3
                                    ? R.color.grayBorder
                                    : R.color.green,
                              ),
                            )
                          : _buildSingleDay(
                              day: _cubit
                                  .timeData?.currentWeek.dayList[index ~/ 2],
                            );
                    },
                  ),
                ),
              ],
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
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: R.color.greenGradientBottom,
        ),
        child: Icon(
          Icons.check_rounded,
          color: R.color.white,
          size: 16.sp,
        ),
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
}
