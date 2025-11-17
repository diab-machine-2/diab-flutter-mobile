import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/bloc/HbA1C/intro_lesson/hba1c_intro_lesson_bloc.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class HbA1cKnowledgeSection extends StatefulWidget {
  const HbA1cKnowledgeSection({Key? key}) : super(key: key);

  @override
  State<HbA1cKnowledgeSection> createState() => _HbA1cKnowledgeSectionState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HbA1cKnowledgeSection(${DateTime.now().millisecondsSinceEpoch})';
  }
}

class _HbA1cKnowledgeSectionState extends State<HbA1cKnowledgeSection> {
  int _currentIndex = 0;
  final double _lessonItemWidth = 338.0;
  final double _itemSpacing = 12.0;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  bool _autoScrollInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize bloc in initState to ensure fresh instance
    _bloc = HbA1cIntroLessonBloc();
    _scrollController.addListener(_onScroll);
    // Force refresh to ensure fresh data
    _bloc.fetchHbA1cIntroLesson(forceRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _stopAutoScroll();
    _bloc.close(); // Close bloc to prevent memory leak
    super.dispose();
  }

  String? _getImageUrl(LessonModel lesson) {
    // First check if url exists and is not empty
    if (lesson.image?.url != null && lesson.image!.url!.isNotEmpty) {
      return lesson.image!.url;
    }

    // If url is empty, try to construct URL using image id
    if (lesson.image?.id != null && lesson.image!.id!.isNotEmpty) {
      final baseURL = FetchClient.baseURL;
      return Uri.https(baseURL, '/App/Image/${lesson.image!.id}').toString();
    }

    // If still empty, return null
    return null;
  }

  // * Scroll listener
  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth;

    int currentIndex = (currentScroll / eachItemWidth).round();
    setState(() {
      _currentIndex = currentIndex;
    });
  }

  void _startAutoScroll(int lessonCount) {
    if (_autoScrollInitialized || lessonCount <= 1) return;
    _autoScrollInitialized = true;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_isUserInteracting || !_scrollController.hasClients) return;
      final int nextIndex = (_currentIndex + 1) % lessonCount;
      final double targetOffset = nextIndex * (_lessonItemWidth + _itemSpacing);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollInitialized = false;
  }

  void _restartAutoScrollWithDelay(int lessonCount) {
    _stopAutoScroll();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isUserInteracting && lessonCount > 1) {
        _startAutoScroll(lessonCount);
      }
    });
  }

  late final HbA1cIntroLessonBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<HbA1cIntroLessonBloc, HbA1cIntroLessonState>(
        builder: (context, state) {
          if (state is HbA1cIntroLessonLoaded) {
            final lessons = state.lessons;

            // If no lessons, don't show the section
            if (lessons.isEmpty) {
              return SizedBox();
            }

            // Start auto scroll after lessons are loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_autoScrollInitialized && lessons.length > 1) {
                _startAutoScroll(lessons.length);
              }
            });

            return _buildLessonsList(lessons);
          } else if (state is HbA1cIntroLessonError) {
            // Hide when error
            return SizedBox();
          }

          // Loading state - show loading indicator
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(R.color.mainColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonsList(List<LessonModel> lessons) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              R.string.knowledge_from_diab_experts.tr(),
              style: TextStyle(
                fontSize: 18,
                fontFamily: R.font.sfpro,
                fontWeight: FontWeight.w700,
                color: R.color.dark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List of lessons
          SizedBox(
            height: 318,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserInteracting = false;
                  _restartAutoScrollWithDelay(lessons.length);
                } else {
                  _isUserInteracting = true;
                  _stopAutoScroll();
                }
                return false;
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SizedBox(
                      child: _buildLessonItem(lessons[index]), height: 318);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemCount: lessons.length,
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 8,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < lessons.length; i++)
                    Container(
                      width: _currentIndex == i ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentIndex == i
                            ? R.color.mainColor
                            : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return SizedBox(
      height: 320.0,
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => _onLessonTap(lesson),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: _getImageUrl(lesson),
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.name,
                        maxLines: 2,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 15.0,
                          height: 24.0 / 15.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Category
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            R.drawable.ic_lesson_category,
                            width: 16.0,
                            height: 16.0,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            lesson.module,
                            style: TextStyle(
                              color: R.color.color0xff666666,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Divider(
                height: 1,
                color: R.color.color0xffE5E5E5,
              ),
              // Actions
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_lesson_share,
                            width: 20.0, height: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          R.string.share.tr(),
                          style: TextStyle(
                              color: R.color.textDark, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLessonTap(LessonModel lesson) async {
    // Track activity
    ActivityListTracking.clickLessonItem(
      objectId: lesson.id,
      objectIndex: null,
      objectTitle: lesson.name,
    );

    // Navigate to lesson detail page
    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lesson.type,
        lessonId: lesson.id,
        onComplete: (_, __) {},
      ),
    );
  }
}
