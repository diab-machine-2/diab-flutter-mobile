import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/intro_lesson/bloodpressure_intro_lesson_bloc.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class BloodPressureLessonSection extends StatefulWidget {
  BloodPressureLessonSection({super.key, required this.onLessonTap});

  final Function(LessonModel) onLessonTap;

  @override
  State<BloodPressureLessonSection> createState() =>
      _BloodPressureLessonSectionState();
}

class _BloodPressureLessonSectionState
    extends State<BloodPressureLessonSection> {
  int _currentIndex = 0;
  final double _lessonItemWidth = 338.0;
  final double _itemSpacing = 12.0;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  bool _autoScrollInitialized = false;

  final _bloc = BloodPressureIntroLessonBloc();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bloc.fetchBloodPressureIntroLesson();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _stopAutoScroll();
    _bloc.close();
    super.dispose();
  }

  // Scroll listener
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth + _itemSpacing;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<BloodPressureIntroLessonBloc,
          BloodPressureIntroLessonState>(builder: (context, state) {
        if (state is BloodPressureIntroLessonLoaded) {
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
        } else if (state is BloodPressureIntroLessonError) {
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
      }),
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
            padding: const EdgeInsets.symmetric(horizontal: 0),
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
                      child: _buildLessonItem(lessons[index]),
                      width: _lessonItemWidth);
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
        onTap: () => widget.onLessonTap(lesson),
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
                  imageUrl: lesson.image?.url,
                  fallbackImageUrl: R.drawable.ic_error_lesson_image,
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
                          fontFamily: R.font.sfpro,
                          fontSize: 15.0,
                          height: 1.3,
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
                              fontFamily: R.font.sfpro,
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
                              color: R.color.textDark,
                              fontSize: 15.0,
                              fontFamily: R.font.sfpro),
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
}
