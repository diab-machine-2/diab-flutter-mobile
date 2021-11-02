import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:medical/src/widgets/video_player_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../activity_feedback/activity_feedback_page.dart';
import '../my_plan/widgets/app_bar_bottom.dart';
import '../select_route/select_route.dart';
import 'activity_tab.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage();

  @override
  _ActivityTabPageState createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage>
    with AutomaticKeepAliveClientMixin<ActivityTabPage> {
  late final ActivityTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository);
    _cubit.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<ActivityTabCubit, ActivityTabState>(
        listener: (context, state) {
          if (state is ActivityTabLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is ActivityTabFailure) {
            Message.showToastMessage(context, state.error);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarBottom(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        NavigationUtil.navigatePage(
                            context, const SelectRoutePage());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Thay đổi lộ trình',
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            R.drawable.ic_start_exercise_bold,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    _buildScheduleWidget(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SmartRefresher(
                    controller: _controller,
                    onRefresh: () => _cubit.refresh(),
                    child: _cubit.data.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 53.w),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.h),
                                  child: Image.asset(
                                      R.drawable.img_activity_empty),
                                ),
                                Text(
                                  'Hôm nay là ngày nghỉ!',
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 20.h),
                            children: [
                              _buildActivityWidget(),
                              _buildActivityWidget(),
                              _buildActivityWidget(),
                              _buildActivityWidget(),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void animateToIndex(int index) {
    if (_cubit.timeData?.weekList.isNotEmpty != true) return;
    if (index < 0) {
      index = 0;
    }
    if (index >= _cubit.timeData!.weekList.length) {
      index = _cubit.timeData!.weekList.length - 1;
    }
    final double newPosition = index * 96 + (6 * index.toDouble());
    _scrollController.jumpTo(newPosition);
    _cubit.onSelectWeek(index);
  }

  Widget _buildWeekListWidget() {
    if (_cubit.timeData == null) return const SizedBox();
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (_cubit.timeData?.currentWeekIndex == null) return;
            animateToIndex(_cubit.timeData!.currentWeekIndex - 1);
          },
          child: Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: (_cubit.timeData?.currentWeekIndex ?? 0) <= 0
                ? R.color.captionColorGray
                : R.color.greenGradientBottom,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(
                _cubit.timeData!.weekList.length,
                (index) => _buildSingleWeek(
                    weekIndex: index,
                    status: _cubit.timeData!.weekList[index].status,
                    isSelected: index == _cubit.timeData?.currentWeekIndex,
                    onSelect: () {
                      _cubit.onSelectWeek(index);
                    }),
              )..add(
                  SizedBox(width: MediaQuery.of(context).size.width - 96 * 2)),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (_cubit.timeData?.currentWeekIndex == null) return;
            animateToIndex(_cubit.timeData!.currentWeekIndex + 1);
          },
          child: Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: (_cubit.timeData?.currentWeekIndex ?? 0) >=
                    ((_cubit.timeData?.weekList.length ?? 1) - 1)
                ? R.color.captionColorGray
                : R.color.greenGradientBottom,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: (127.h - 87.w) / 2),
      height: 87.w,
      alignment: Alignment.center,
      color: R.color.transparent,
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
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Bài 1. Vận động mạnh và dài nhất có thể nè mọi ae',
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '5 phút',
                      style: TextStyle(
                          color: R.color.grey_2,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCustomIconButton(
                        title: 'Bắt đầu tập',
                        icon: R.drawable.ic_start_exercise,
                        borderColor: R.color.greenGradientBottom,
                        backgroundColor: R.color.greenGradientBottom,
                        textColor: R.color.white,
                        onTap: () {
                          NavigationUtil.navigatePage(
                              context,
                              const VideoPlayerWidget(
                                title: 'Bài 1. Vận động mạnh và phù hợp',
                                videoUrl:
                                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                              ));
                        }),
                    _buildCustomIconButton(
                      title: 'Xem hướng dẫn',
                      icon: R.drawable.ic_play,
                      borderColor: R.color.greenGradientBottom,
                      backgroundColor: R.color.white,
                      textColor: R.color.greenGradientBottom,
                    ),
                  ],
                ),
                // _buildLessonStatusWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomIconButton({
    required String title,
    required String icon,
    required Color borderColor,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: R.color.main_6,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                icon,
                width: 16.w,
                height: 16.w,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 4.h, 8.w, 4.h),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          _buildWeekListWidget(),
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
    required CompletionStatus status,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 6),
        width: 96,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? R.color.blue_6 : R.color.transparent,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tuần ${weekIndex + 1}',
              style: TextStyle(
                color: isSelected
                    ? R.color.greenGradientBottom
                    : status.statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            status.weekStatusIcon
          ],
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

  @override
  bool get wantKeepAlive => true;
}
