import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/plan_type.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../my_plan/my_plan.dart';
import '../lesson_detail/lesson_detail.dart';
import 'lesson_tab.dart';

/// Recommendation filter chip: type index -> label.
const Map<int, String> _recommendationChipLabels = {
  0: 'Tất cả',
  1: 'Theo dõi chỉ số',
  2: 'Tinh thần',
  3: 'Tâm lý hành vi',
  4: 'Dinh dưỡng',
  5: 'Bệnh lý',
  6: 'Vận động',
};

class LessonTabPage extends StatefulWidget {
  const LessonTabPage();

  @override
  _LessonTabPageState createState() => _LessonTabPageState();
}

class _LessonTabPageState extends State<LessonTabPage>
    with AutomaticKeepAliveClientMixin<LessonTabPage>, Observer {
  late final LessonTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _lessonScrollController = ScrollController();
  final ScrollController _weekScrollController = ScrollController();
  final GlobalKey _lessonTabBottomLoadingKey = GlobalKey();
  final GlobalKey _recommendationLoadingKey = GlobalKey();

  int currentPageRoad = 1;
  int currentPageSuggest = 1;
  bool isLoading = false;
  bool _didShowInitialBotToast = false;

  /// True while BotToast loading overlay is shown (kept in sync with show/close calls).
  bool _botToastLessonLoadingVisible = false;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = LessonTabCubit(appRepository, _myPlanCubit);
    // Trigger loads after the first frame so BlocConsumer listeners are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure the first navigation always shows bot loading.
      if (!_didShowInitialBotToast) {
        _didShowInitialBotToast = true;
        _setBotToastLessonLoadingVisible(true);
        BotToast.showLoading();
      }
      // Await main list first so getRecommendationLessons cannot emit Initial/Success
      // while lessons are still loading (which briefly showed the empty placeholder).
      await _cubit.getInitData();
      await _cubit.getForYouLessons();
      await _cubit.getRecommendationLessons(type: 0);
    });

    _lessonScrollController.addListener(() {
      if (_lessonScrollController.position.pixels ==
          _lessonScrollController.position.maxScrollExtent) {
        if (_cubit.currentLessonTypeIndex == 0) {
          _cubit.getInitData(currentPage: ++currentPageRoad);
        } else {
          _cubit.getInitData(currentPage: ++currentPageSuggest);
        }
      }
    });
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    _controller.dispose();
    _lessonScrollController.dispose();
    _weekScrollController.dispose();
    super.dispose();
  }

  @override
  void update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'switch_lesson_tab') {
      _cubit.scrollToLesson();
    }

    if (notifyName == 'refresh_lesson_tab') {
      await _cubit.getInitData(isRefresh: true, showCurrentWeek: false);
      await _cubit.getForYouLessons();
      // Re-load recommendations so learning status in the list is updated
      // right after completing a lesson.
      await _cubit.getRecommendationLessons(type: _cubit.recommendationType);
    }
    if (notifyName == Const.NAVIGATE_TO_LESSON_DETAIL) {
      if (_cubit.lessonsList == null) {
        await _cubit.getInitData(isRefresh: true, showCurrentWeek: false);
        _setBotToastLessonLoadingVisible(true);
        BotToast.showLoading();
      } else {
        _checkExistLessonId();
      }
    }
  }

  void _setBotToastLessonLoadingVisible(bool visible) {
    if (_botToastLessonLoadingVisible == visible) return;
    setState(() => _botToastLessonLoadingVisible = visible);
  }

  _checkExistLessonId() async {
    final String? lessonId = BranchioLinkConfig.instance.lessonId;
    if (lessonId != null) {
      Navigator.pushNamed(context, NavigatorName.lesson_detail, arguments: {
        'lessonId': lessonId,
        'lessonType': PlanType.lesson.planTypeIndex,
      });
      BranchioLinkConfig.instance.removeLessonId();
    }
  }

  void _scrollToWidget(GlobalKey key) {
    final currentContext = key.currentContext;
    if (currentContext != null) {
      Scrollable.ensureVisible(
        currentContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    if (_lessonScrollController.hasClients) {
      final max = _lessonScrollController.position.maxScrollExtent;
      _lessonScrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<LessonTabCubit, LessonTabState>(
        listener: (context, state) {
          if (state is LessonTabSuccess) {
            _checkExistLessonId();
            if (_cubit.isRecommendationLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToWidget(_recommendationLoadingKey);
              });
            }
          }
          if (state is LessonTabLoadMore) {
            setState(() {
              isLoading = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToWidget(_lessonTabBottomLoadingKey);
            });
          } else if (state is LessonTabLoading) {
            if (!_didShowInitialBotToast) {
              _setBotToastLessonLoadingVisible(true);
              BotToast.showLoading();
            }
          } else {
            if (state is! LessonTabWeekChanged) {
              BotToast.closeAllLoading();
              _setBotToastLessonLoadingVisible(false);
              _didShowInitialBotToast = false;
              setState(() {
                isLoading = false;
              });
            }
            _controller.refreshCompleted();
          }
          if (state is LessonTabFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is LessonTabWeekChanged) {
            animateToIndex(state.newIndex, refresh: false);
          }
          if (state is LessonTabScrollToLesson) {
            if (_lessonScrollController.hasClients) {
              if (_cubit.lessonsList != null &&
                  _cubit.lessonsList!.length > 5) {
                _lessonScrollController.jumpTo(
                  127.0 * state.newIndex,
                );
              }
            }
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Container(
              //   color: R.color.white,
              //   child: Column(
              //     children: [
              //       Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              //         ...List.generate(
              //           _cubit.lessonTypeList.length,
              //           (index) {
              //             return _buildLessonTypeSelect(
              //               title: _cubit.lessonTypeList[index].title,
              //               isActive: _cubit.currentLessonTypeIndex == index,
              //               onTap: () {
              //                 if (_cubit.lessonTypeList[index] ==
              //                     LessonType.suggest) {
              //                   LessonDetailTracking.tabLessonRecommend();
              //                 }
              //                 _cubit.changeLessonType(index);
              //               },
              //             );
              //           },
              //         ),
              //         const Spacer(),
              //         InkWell(
              //           onTap: () async {
              //             final FilterData newFilter =
              //                 _cubit.filterData.copyWith();
              //             final dynamic result =
              //                 await NavigationUtil.navigatePage(
              //               context,
              //               LessonFilterPage(
              //                 newFilter,
              //               ),
              //             );
              //             if (result is FilterData) {
              //               _cubit.filterData = result;
              //               _cubit.RefreshDataOfList();
              //               _cubit.getInitData(currentPage: 1);
              //             } else {
              //               _cubit.refresh();
              //             }
              //           },
              //           child: Padding(
              //             padding: const EdgeInsets.only(bottom: 12),
              //             child: Stack(
              //               children: [
              //                 Column(
              //                   children: [
              //                     const SizedBox(height: 3, width: 24),
              //                     Image.asset(
              //                       R.drawable.ic_filter_lesson,
              //                       width: 20,
              //                       height: 20,
              //                     ),
              //                   ],
              //                 ),
              //                 Visibility(
              //                   visible: !_cubit.filterData.isEmpty,
              //                   child: Positioned(
              //                     top: 0,
              //                     right: 0,
              //                     child: Container(
              //                       width: 10,
              //                       height: 10,
              //                       decoration: BoxDecoration(
              //                         color: R.color.greenGradientTop,
              //                         shape: BoxShape.circle,
              //                         border: Border.all(
              //                             width: 2, color: R.color.white),
              //                       ),
              //                     ),
              //                   ),
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //       ]),
              //     ],
              //   ),
              // ),
              // Lesson list
              Expanded(
                child: _cubit.lessonsList?.isEmpty == null
                    ? const SizedBox.shrink()
                    : Stack(
                        children: [
                          SafeArea(
                            top: false,
                            child: SmartRefresher(
                              controller: _controller,
                              scrollController: _lessonScrollController,
                              onRefresh: () {
                                currentPageRoad = 1;
                                currentPageSuggest = 1;
                                _cubit.onRefresh(isRefresh: true);
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildForYouSection(),
                                    if (_cubit.lessonsList!.isEmpty)
                                      (state is LessonTabLoading)
                                          ? SizedBox(
                                              height: 220.h,
                                              width: double.infinity,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: R.color
                                                      .greenGradientBottom,
                                                ),
                                              ),
                                            )
                                          : (state is LessonTabWeekChanged)
                                              ? Container()
                                              : _buildEmptyLessonList()
                                    else
                                      _buildGroupedLessonList(),
                                    _buildRecommendationSection(state),
                                    if (_cubit.lessonsList!.isNotEmpty)
                                      Container(
                                          height: 24.h, color: R.color.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Group current lesson list by module and render each module as a section.
  Widget _buildGroupedLessonList() {
    final List<MyLessonResponseData?> lessons = _cubit.lessonsList ?? [];
    if (lessons.isEmpty) return const SizedBox.shrink();

    // Map: module name -> list of indices in lessonsList.
    final Map<String, List<int>> moduleIndexMap = {};
    for (int i = 0; i < lessons.length; i++) {
      final MyLessonResponseData? lesson = lessons[i];
      final String rawModule = lesson?.module ?? '';
      final String moduleName =
          rawModule.trim().isEmpty ? R.string.title_route.tr() : rawModule;
      moduleIndexMap.putIfAbsent(moduleName, () => <int>[]).add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: moduleIndexMap.entries.map((entry) {
        final String moduleName = entry.key;
        final List<int> indices = entry.value;
        final List<MyLessonResponseData?> moduleLessons =
            indices.map((i) => _cubit.lessonsList?[i]).toList();
        return Container(
          color: R.color.white,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  NavigationUtil.navigatePage(
                    context,
                    ModuleLessonsPage(
                      moduleName: moduleName,
                      lessons: moduleLessons,
                      cubit: _cubit,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          moduleName,
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: R.color.greenGradientBottom,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: indices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final int lessonIndex = indices[idx];
                    final lesson = _cubit.lessonsList?[lessonIndex];
                    return _buildModuleLessonCard(
                      lessonDetail: lesson,
                      onTap: () async {
                        if (lesson?.id?.isNotEmpty == true) {
                          ActivityListTracking.clickLessonItem(
                            objectId: lesson!.id,
                            objectIndex: lessonIndex,
                            objectTitle: lesson.name,
                          );
                          debugPrint(
                              '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Navigating to LessonDetailPage for id=' +
                                  (lesson.id ?? '') +
                                  ' name=' +
                                  (lesson.name ?? ''));
                          await NavigationUtil.navigatePage(
                            context,
                            LessonDetailPage(
                              lessonType: lesson.type,
                              lessonId: lesson.id!,
                              onComplete: (lessonId, percentComplete) {
                                _cubit.updateStatusLesson(
                                  lessonId: lessonId,
                                  percentComplete: percentComplete,
                                );
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// "Dành cho bạn" section shown above all lesson modules.
  Widget _buildForYouSection() {
    final lessons = _cubit.forYouLessons ?? [];
    if (lessons.isEmpty && !_cubit.isForYouLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      color: R.color.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Dành cho bạn',
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_cubit.isForYouLoading)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 130,
              child: Center(
                child: CircularProgressIndicator(
                  color: R.color.greenGradientBottom,
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildForYouLessonCard(
                    lessonDetail: lesson,
                    onTap: () async {
                      if (lesson?.id?.isNotEmpty == true) {
                        ActivityListTracking.clickLessonItem(
                          objectId: lesson!.id,
                          objectIndex: index,
                          objectTitle: lesson.name,
                        );
                        await NavigationUtil.navigatePage(
                          context,
                          LessonDetailPage(
                            lessonType: lesson.type,
                            lessonId: lesson.id!,
                            onComplete: (lessonId, percentComplete) {
                              _cubit.updateStatusLesson(
                                lessonId: lessonId,
                                percentComplete: percentComplete,
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// \"Đề xuất\" section at bottom using recommendationLessons.
  Widget _buildRecommendationSection(LessonTabState state) {
    final lessons = _cubit.recommendationLessons ?? [];
    final bool hideRecommendationFilters =
        state is LessonTabLoading || _botToastLessonLoadingVisible;
    return hideRecommendationFilters
        ? const SizedBox.shrink()
        : Container(
            color: R.color.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    R.string.recommended.tr(),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recommendationChipLabels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isActive = _cubit.recommendationType == index;
                      final label = _recommendationChipLabels[index] ?? '';
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _cubit.getRecommendationLessons(type: index);
                          },
                          borderRadius: BorderRadius.circular(200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? R.color.greenGradientBottom
                                  : R.color.white,
                              borderRadius: BorderRadius.circular(200),
                              border: isActive
                                  ? null
                                  : Border.all(color: R.color.captionColorGray),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isActive
                                    ? R.color.white
                                    : R.color.captionColorGray,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_cubit.isRecommendationLoading)
                  KeyedSubtree(
                    key: _recommendationLoadingKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 130,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: Colors.transparent,
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: R.color.greenGradientBottom,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    lessons.length,
                    (index) => _buildRecommendationRow(
                      lessonDetail: lessons[index],
                      onTap: () async {
                        final lesson = lessons[index];
                        if (lesson?.id?.isNotEmpty == true) {
                          ActivityListTracking.clickLessonItem(
                            objectId: lesson!.id,
                            objectIndex: index,
                            objectTitle: lesson.name,
                          );

                          await NavigationUtil.navigatePage(
                            context,
                            LessonDetailPage(
                              lessonType: lesson.type,
                              lessonId: lesson.id!,
                              onComplete: (lessonId, percentComplete) {
                                _cubit.updateStatusLesson(
                                  lessonId: lessonId,
                                  percentComplete: percentComplete,
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
  }

  void animateToIndex(int index, {bool refresh = true}) {
    if (_cubit.weekStatesList.isEmpty) return;
    if (index < 0) {
      index = 0;
      refresh = false;
    }
    if (index >= _cubit.weekStatesList.length) {
      index = _cubit.weekStatesList.length - 1;
      refresh = false;
    }
    if (_weekScrollController.hasClients) {
      final double newPosition = index * 96 + (6 * index.toDouble());
      _weekScrollController.animateTo(
        newPosition,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
    if (refresh) {
      _cubit.onSelectWeek(index);
    }
  }

  Widget _buildEmptyLessonList() {
    return Column(
      children: [
        SizedBox(height: 70.h),
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

  /// Row style for recommendation list: module -> title -> book icon + duration + arrow.
  Widget _buildRecommendationRow({
    required LessonSectionListResponseData? lessonDetail,
    VoidCallback? onTap,
  }) {
    final String module = lessonDetail?.lessonModule?.name ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: R.color.grey_6),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image on the left
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: NetWorkImageWidget(imageUrl: lessonDetail?.image?.url),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (module.isNotEmpty)
                    Text(
                      module,
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 4),
                  LessonStatusWidget(
                    learningStatus: lessonDetail?.learningStatus,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: R.color.greenGradientBottom,
            ),
          ],
        ),
      ),
    );
  }

  /// Card for horizontal module list (image -> module/category -> name -> book icon + duration).
  Widget _buildModuleLessonCard({
    required MyLessonResponseData? lessonDetail,
    VoidCallback? onTap,
  }) {
    final String category = lessonDetail?.module ?? '';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: R.color.grey_6),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: NetWorkImageWidget(imageUrl: lessonDetail?.image?.url),
              ),
            ),
            const SizedBox(height: 8),
            if (category.isNotEmpty)
              Text(
                category,
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Text(
                lessonDetail?.name ?? '',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            LessonStatusWidget(
              learningStatus: lessonDetail?.learningStatus,
            ),
          ],
        ),
      ),
    );
  }

  /// Card for horizontal "Dành cho bạn" list.
  Widget _buildForYouLessonCard({
    required LessonSectionListResponseData? lessonDetail,
    VoidCallback? onTap,
  }) {
    final String category = lessonDetail?.lessonModule?.name ?? '';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: R.color.grey_6),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: NetWorkImageWidget(imageUrl: lessonDetail?.image?.url),
              ),
            ),
            const SizedBox(height: 8),
            if (category.isNotEmpty)
              Text(
                category,
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Text(
                lessonDetail?.name ?? '',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            LessonStatusWidget(
              learningStatus: lessonDetail?.learningStatus,
            ),
          ],
        ),
      ),
    );
  }

  void showUpdateRequirePopup({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF008076),
                Color(0xFF0DA99C),
                Color(0xFFEAF9F7),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: Image.asset(
                  R.drawable.img_upgrade_package_v2,
                  width: 35,
                  height: 35,
                ),
              ),
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                ),
                child: Text(
                  R.string.unlock_advanced_lessons.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GapH(16),
              Container(
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: MediaQuery.of(context).textScaler.clamp(
                                minScaleFactor: 1.0, maxScaleFactor: 1.3),
                          ),
                          child: Text(
                            R.string.membership_benefits.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GapH(12),
                    _benefitRow(
                        R.string
                            .pathology_nutrition_exercise_psychology_knowledge_diverse
                            .tr(),
                        R.string.pathology_nutrition_knowledge.tr()),
                    _benefitRow(
                        R.string.personalized_healthy_lifestyle_roadmap.tr(),
                        R.string.healthy_lifestyle_roadmap.tr()),
                    _benefitRow(R.string.use_all_advanced_features.tr(),
                        R.string.advanced_features.tr()),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Observable.instance.notifyObservers(
                          [],
                          notifyName: Const
                              .NAVIGATE_TO_MY_PLAN_TAB_AUTO_TRIGGER_SUBSCRIPTION,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        height: 48,
                        decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom,
                              R.color.greenGradientBottom,
                            ],
                          ),
                        ),
                        child: Center(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: MediaQuery.of(context)
                                  .textScaler
                                  .clamp(
                                      minScaleFactor: 1.0, maxScaleFactor: 1.3),
                            ),
                            child: Text(
                              R.string.tim_hieu_them.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _benefitRow(String text, String boldPart) {
    final parts = text.split(boldPart);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            R.drawable.ic_subscription_bullet,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: parts[0]),
                  TextSpan(
                    text: boldPart,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (parts.length > 1) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
