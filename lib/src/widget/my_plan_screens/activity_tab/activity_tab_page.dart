import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../activity_feedback/activity_feedback_page.dart';
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

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository);
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
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    NavigationUtil.navigatePage(
                        context, const SelectRoutePage());
                  },
                  child: Row(
                    children: [
                      Text(
                        'Lộ trình dành cho người thể trạng yếu',
                        style: TextStyle(
                          color: R.color.greenGradientBottom,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
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
                                    padding:
                                        EdgeInsets.symmetric(vertical: 24.h),
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
                              padding: EdgeInsets.zero,
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
            ),
          );
        },
      ),
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
                      onTap: (){
                        NavigationUtil.navigatePage(context, const ActivityFeedbackPage());
                      }
                    ),
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

  @override
  bool get wantKeepAlive => true;
}
