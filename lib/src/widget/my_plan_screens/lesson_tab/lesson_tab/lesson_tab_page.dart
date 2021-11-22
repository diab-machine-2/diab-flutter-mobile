import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import '../lesson_detail/lesson_detail.dart';
import '../lesson_filter/lesson_filter.dart';
import '../lesson_filter/models/filter_data.dart';
import 'lesson_tab.dart';
import 'models/completion_status.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = LessonTabCubit(appRepository, _myPlanCubit);
    _cubit.getInitData();
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
          if (state is LessonTabWeekChanged) {
            animateToIndex(state.newIndex, refresh: false);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBarBottom(
                child: Column(
                  children: [
                    _buildWeekListWidget(),
                    Row(children: [
                      ...List.generate(
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
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          final dynamic result =
                              await NavigationUtil.navigatePage(
                            context,
                            LessonFilterPage(
                              _cubit.filterData.copyWith(),
                            ),
                          );
                          if (result is FilterData) {
                            _cubit.filterData = result;
                            _cubit.getInitData();
                          }
                          _cubit.refresh();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 3, width: 24),
                                  Image.asset(
                                    R.drawable.ic_filter_lesson,
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: !_cubit.filterData.isEmpty,
                                child: Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: R.color.greenGradientTop,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: R.color.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              //Lesson list
              Expanded(
                child: _cubit.lessonsList?.isEmpty == null
                    ? const SizedBox.shrink()
                    : SafeArea(
                        top: false,
                        child: SmartRefresher(
                          controller: _controller,
                          onRefresh: () =>
                              _cubit.getLessonsList(isRefresh: true),
                          child: _cubit.lessonsList!.isEmpty
                              ? _buildEmptyLessonList()
                              : SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(
                                      _cubit.lessonsList?.length ?? 0,
                                      (index) => _buildLessonWidget(
                                          lessonDetail:
                                              _cubit.lessonsList?[index],
                                          onTap: () {
                                            if (_cubit.lessonsList?[index]?.id
                                                    ?.isNotEmpty ==
                                                true) {
                                              NavigationUtil.navigatePage(
                                                context,
                                                LessonDetailPage(
                                                  _cubit
                                                      .lessonsList![index]!.id!,
                                                ),
                                              );
                                            }
                                          }),
                                    )
                                      ..insert(0, SizedBox(height: 20.h))
                                      ..add(SizedBox(height: 20.h)),
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

  void animateToIndex(int index, {bool refresh = true}) {
    if (_cubit.weekList.isNotEmpty != true) return;
    if (index < 0) {
      index = 0;
      refresh = false;
    }
    if (index >= _cubit.weekList.length) {
      index = _cubit.weekList.length - 1;
      refresh = false;
    }
    final double newPosition = index * 96 + (6 * index.toDouble());
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
    if (refresh) {
      _cubit.onSelectWeek(index);
    }
  }

  Widget _buildWeekListWidget() {
    if (_cubit.weekList.isNotEmpty != true) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (_cubit.currentWeekIndex == null || _cubit.isFiltering) return;
              animateToIndex(_cubit.currentWeekIndex - 1);
            },
            child: Icon(
              Icons.chevron_left_rounded,
              size: 24,
              color: _cubit.currentWeekIndex <= 0 || _cubit.isFiltering
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
                  _cubit.weekList.length,
                  (index) => _buildSingleWeek(
                      weekIndex: index,
                      status: _cubit.weekList[index],
                      isSelected: index == _cubit.currentWeekIndex,
                      isDisable: _cubit.isFiltering,
                      onSelect: () {
                        _cubit.onSelectWeek(index);
                      }),
                )..add(SizedBox(
                    width: MediaQuery.of(context).size.width - 96 * 2)),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (_cubit.currentWeekIndex == null || _cubit.isFiltering) return;
              animateToIndex(_cubit.currentWeekIndex + 1);
            },
            child: Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: _cubit.currentWeekIndex >= (_cubit.weekList.length - 1) ||
                      _cubit.isFiltering
                  ? R.color.captionColorGray
                  : R.color.greenGradientBottom,
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
    bool isDisable = false,
    VoidCallback? onSelect,
  }) {
    final Color background =
        isSelected && status == CompletionStatus.not_start_yet
            ? R.color.greenbg
            : status.statusBackgroundColor;
    final BoxBorder? border =
        isSelected && status != CompletionStatus.not_start_yet
            ? Border.all(color: status.statusIconColor)
            : null;
    final Color textColor =
        isSelected && status == CompletionStatus.not_start_yet
            ? R.color.green
            : status.statusIconColor;
    final bool showIcon =
        !(isSelected && status == CompletionStatus.not_start_yet);

    return GestureDetector(
      onTap: isDisable
          ? () {}
          : () {
              onSelect?.call();
            },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 6),
        width: 96,
        height: 32,
        decoration: BoxDecoration(
          color: isDisable ? R.color.grey_6 : background,
          border: isDisable ? null : border,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${R.string.week_upper_case_first.tr()} ${weekIndex + 1}',
              style: TextStyle(
                color: isDisable ? R.color.grayCaption : textColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showIcon && !isDisable) status.weekStatusIcon
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTypeSelect({
    required String title,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
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
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Container(
            width: 105,
            height: 3,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: isActive ? R.color.mainColor : R.color.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLessonList() {
    return Column(
      children: [
        SizedBox(height: 116.h),
        if (_cubit.isFiltering)
          Image.asset(
            R.drawable.img_lesson_locked,
            width: 200.w,
            height: 200.w,
          )
        else
          Image.asset(
            R.drawable.img_activity_empty,
            width: 268.w,
            height: 200.w,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 24, 50, 6),
          child: Text(
            _cubit.isFiltering
                ? R.string.no_matched_lesson.tr()
                : R.string.lesson_empty_no_filter.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Text(
            _cubit.isFiltering
                ? R.string.no_matched_lesson_description.tr()
                : R.string.lesson_empty_no_filter_description.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonWidget({
    required MyLessonResponseData? lessonDetail,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 87,
      alignment: Alignment.center,
      color: R.color.transparent,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                if (lessonDetail?.level != 'Cấp độ 1') {
                  //TODO: Show dialog upgrade
                }
                if (lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
                  _showLockedDialog();
                  return;
                }
                onTap?.call();
              },
              child: Row(
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      height: 87,
                      width: 87,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: NetWorkImageWidget(
                          imageUrl: lessonDetail?.image?.url)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                lessonDetail?.tagName ?? '',
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (lessonDetail?.isNew == true)
                                Image.asset(
                                  R.drawable.ic_new_lesson,
                                  width: 24,
                                  height: 24,
                                )
                            ],
                          ),
                          Text(
                            lessonDetail?.name ?? '',
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          LessonStatusWidget(
                            learningStatus: lessonDetail?.learningStatus,
                            progress: lessonDetail?.percentComplete,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: lessonDetail?.learningStatus == Const.LESSON_LOCKED
                        ? R.color.captionColorGray
                        : R.color.greenGradientBottom,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _showLockedDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: GestureDetector(
            child: Container(
              width: 344,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.color.white,
                    R.color.main_6,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(84.w, 0, 84.w, 20),
                    child: Image.asset(
                      R.drawable.img_lesson_locked,
                    ),
                  ),
                  Text(
                    R.string.lesson_locked.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    R.string.lesson_locked_warning.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ButtonWidget(
                      height: 43,
                      title: R.string.agree.tr(),
                      onPressed: () {
                        NavigationUtil.pop(context);
                      },
                      textSize: 14,
                    ),
                  )
                ],
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
