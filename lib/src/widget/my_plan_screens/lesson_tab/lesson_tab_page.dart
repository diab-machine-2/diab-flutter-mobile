import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/dashed_vertical_line.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../lesson_detail/lesson_detail.dart';
import 'lesson_tab.dart';
import 'models/lesson_type.dart';

class LessonTabPage extends StatefulWidget {
  const LessonTabPage();

  @override
  _LessonTabPageState createState() => _LessonTabPageState();
}

class _LessonTabPageState extends State<LessonTabPage>
    with AutomaticKeepAliveClientMixin<LessonTabPage> {
  late final LessonTabCubit _cubit;
  final RefreshController _controller = RefreshController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = LessonTabCubit(appRepository);
    _cubit.getLessonsList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<LessonTabCubit, LessonTabState>(
        listener: (context, state) {
          if (state is LessonTabLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is LessonTabFailure) {
            Message.showToastMessage(context, state.error);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 20.h,
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
                        },
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SmartRefresher(
                    controller: _controller,
                    onRefresh: () => _cubit.getLessonsList(isRefresh: true),
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Visibility(
                            visible:
                                _cubit.currentLessonType == LessonType.route,
                            child: Positioned(
                              top: (127.h) / 2 + 20.h,
                              left: 19.5.w,
                              child: Container(
                                height: max(
                                    (_cubit.lessonsList.length - 1) * 127.h, 0),
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
                                    if (_cubit.lessonsList[index]?.id
                                            ?.isNotEmpty ==
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
              ),
            ],
          );
        },
      ),
    );
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
                          Row(
                            children: [
                              Text(
                                lessonDetail?.module ?? '',
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Image.asset(
                                R.drawable.ic_new_lesson,
                                width: 24.w,
                                height: 24.w,
                              )
                            ],
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
                          LessonStatusWidget(
                            learningStatus: lessonDetail?.learningStatus,
                            progress: lessonDetail?.percentComplete,
                            isRequired:
                                _cubit.currentLessonType == LessonType.route,
                          ),
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

  Color getBorderColor(int? learningStatus) {
    if (learningStatus == Const.LESSON_LEARNT)
      return R.color.greenGradientBottom;
    if (learningStatus == Const.LESSON_LEARNING) return R.color.color0xff50C087;
    return R.color.color0xffC0C2C5;
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

  @override
  bool get wantKeepAlive => true;
}
