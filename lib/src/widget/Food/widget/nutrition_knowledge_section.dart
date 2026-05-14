import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/food/nutrition_lesson.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

/// Widget hiển thị "Kiến thức từ Chuyên gia DiaB"
/// Dữ liệu từ FoodClient().fetchNutritionLessons()
class NutritionKnowledgeSection extends StatefulWidget {
  final int position;

  const NutritionKnowledgeSection({Key? key, this.position = 7})
      : super(key: key);

  @override
  State<NutritionKnowledgeSection> createState() =>
      _NutritionKnowledgeSectionState();
}

class _NutritionKnowledgeSectionState extends State<NutritionKnowledgeSection> {
  int _currentIndex = 0;
  final double _itemWidth = 338.0;
  final double _itemSpacing = 12.0;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  bool _autoScrollInitialized = false;

  List<NutritionLesson> _lessons = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _stopAutoScroll();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final lessons = await FoodClient().fetchNutritionLessons();
      if (mounted) {
        setState(() {
          _lessons = lessons ?? [];
          _isLoading = false;
        });
        if (_lessons.length > 1) {
          _startAutoScroll(_lessons.length);
        }
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _itemWidth + _itemSpacing;
    int currentIndex = (currentScroll / eachItemWidth).round();
    if (currentIndex != _currentIndex && currentIndex < _lessons.length) {
      setState(() {
        _currentIndex = currentIndex;
      });
    }
  }

  void _startAutoScroll(int itemCount) {
    if (_autoScrollInitialized || itemCount <= 1) return;
    _autoScrollInitialized = true;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_isUserInteracting || !_scrollController.hasClients) return;
      final int nextIndex = (_currentIndex + 1) % itemCount;
      final double targetOffset = nextIndex * (_itemWidth + _itemSpacing);
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

  void _restartAutoScrollWithDelay(int itemCount) {
    _stopAutoScroll();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isUserInteracting && itemCount > 1) {
        _startAutoScroll(itemCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
    }

    if (_hasError || _lessons.isEmpty) {
      return SizedBox();
    }

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
          SizedBox(
            height: 300,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserInteracting = false;
                  _restartAutoScrollWithDelay(_lessons.length);
                } else {
                  _isUserInteracting = true;
                  _stopAutoScroll();
                }
                return false;
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 12, right: 12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _buildLessonItem(_lessons[index]);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: _itemSpacing);
                },
                itemCount: _lessons.length,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_lessons.length > 1)
            SizedBox(
              height: 8,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _lessons.length; i++)
                      Container(
                        width: _currentIndex == i ? 16 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentIndex == i
                              ? R.color.mainColor
                              : Colors.grey.shade300,
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

  Widget _buildLessonItem(NutritionLesson lesson) {
    return SizedBox(
      height: 300,
      width: _itemWidth,
      child: InkWell(
        onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: lesson.imageUrl,
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12.0),
              // Lesson content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lesson title
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: MediaQuery.of(context)
                              .textScaler
                              .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                        ),
                        child: Text(
                          lesson.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            height: 24.0 / 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Divider
              Divider(height: 1, color: R.color.color0xffE5E5E5),
              // Share button
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          R.drawable.ic_lesson_share,
                          width: 20.0,
                          height: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          R.string.share.tr(),
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 15.0,
                          ),
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

  void _navigateToLessonDetail(String id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id,
        onComplete: (_, __) {},
      ),
    );
  }
}
