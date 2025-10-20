import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:medical/res/R.dart';

// Simple mock lesson class for this component
class MockLesson {
  final String id;
  final String name;
  final String module;
  final String imagePath;

  const MockLesson({
    required this.id,
    required this.name,
    required this.module,
    required this.imagePath,
  });
}

class HbA1cKnowledgeSection extends StatefulWidget {
  const HbA1cKnowledgeSection({Key? key}) : super(key: key);

  @override
  State<HbA1cKnowledgeSection> createState() => _HbA1cKnowledgeSectionState();
}

class _HbA1cKnowledgeSectionState extends State<HbA1cKnowledgeSection> {
  List<MockLesson> lessons = [];
  bool isLoading = true;
  int _currentIndex = 0;
  final double _lessonItemWidth = 288.0;
  final double _itemSpacing = 12.0;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  bool _autoScrollInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMockData();
  }

  void _loadMockData() {
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          lessons = _getMockLessons();
          isLoading = false;
          _startAutoScroll();
        });
      }
    });
  }

  List<MockLesson> _getMockLessons() {
    return const [
      MockLesson(
        id: '1',
        name: 'HbA1c là gì? Ý nghĩa của chỉ số HbA1c',
        module: 'Kiến thức cơ bản',
        imagePath: 'im_hba1c_supports_1',
      ),
      MockLesson(
        id: '2',
        name: 'Cách theo dõi và quản lý HbA1c hiệu quả',
        module: 'Quản lý bệnh',
        imagePath: 'im_hba1c_supports_2',
      ),
      MockLesson(
        id: '3',
        name: 'Mục tiêu HbA1c theo khuyến cáo của chuyên gia',
        module: 'Mục tiêu điều trị',
        imagePath: 'im_hba1c_supports_3',
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _stopAutoScroll();
    super.dispose();
  }

  // * Scroll listener
  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth + _itemSpacing;

    int currentIndex = (currentScroll / eachItemWidth).round();
    if (currentIndex != _currentIndex &&
        currentIndex >= 0 &&
        currentIndex < lessons.length) {
      setState(() {
        _currentIndex = currentIndex;
      });
    }
  }

  void _startAutoScroll() {
    if (_autoScrollInitialized || lessons.length <= 1) return;
    _autoScrollInitialized = true;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_isUserInteracting || !_scrollController.hasClients) return;
      final int nextIndex = (_currentIndex + 1) % lessons.length;
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

  void _restartAutoScrollWithDelay() {
    _stopAutoScroll();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isUserInteracting && lessons.length > 1) {
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (lessons.isEmpty) {
      return _buildEmptyState();
    }

    return _buildLessonsList();
  }

  Widget _buildLoadingState() {
    return Container(
      // width: 351,
      height: 426,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLessonsList() {
    return Container(
      // width: 351,
      height: 426,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kiến thức từ Chuyên gia DiaB",
            style: TextStyle(
              fontFamily: R.font.sfpro,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.dark,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          // List of lessons
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserInteracting = false;
                  _restartAutoScrollWithDelay();
                } else {
                  _isUserInteracting = true;
                  _stopAutoScroll();
                }
                return false;
              },
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _buildLessonItem(lessons[index]);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemCount: lessons.length,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pagination indicators
          if (lessons.length > 1)
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: 351,
      height: 426,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kiến thức từ Chuyên gia DiaB",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.dark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: R.color.greenbg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 32,
                      color: R.color.primaryGreyColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Chưa có bài viết nào",
                      style: TextStyle(
                        color: R.color.primaryGreyColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(MockLesson lesson) {
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.asset(
                  R.drawable.im_hba1c_supports_1, // Use a default image for now
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
                          fontFamily: R.font.sfpro,
                          color: R.color.textDark,
                          fontSize: 15.0,
                          height: 24.0 / 15.0,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Module info
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
                    onTap: () => _onLessonTap(lesson),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_lesson_share,
                            width: 20.0, height: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          "Xem chi tiết",
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 15.0,
                              fontFamily: R.font.sfpro,
                              letterSpacing: 0.4),
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

  void _onLessonTap(MockLesson lesson) {
    // For mock data, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bài học "${lesson.name}" sẽ được mở trong tương lai'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
