import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget hiển thị "Kiến thức từ Chuyên gia DiaB"
/// UI giống HbA1cKnowledgeSection, dữ liệu từ LearningPost API
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

  List<LearningPostModel> _posts = [];
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
      final posts = await LearningClient().fetchLearningPost(widget.position);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
        if (_posts.length > 1) {
          _startAutoScroll(_posts.length);
        }
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
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
    if (currentIndex != _currentIndex && currentIndex < _posts.length) {
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

    if (_hasError || _posts.isEmpty) {
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
          // List of posts
          SizedBox(
            height: 318,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserInteracting = false;
                  _restartAutoScrollWithDelay(_posts.length);
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
                  return _buildPostItem(_posts[index]);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: _itemSpacing);
                },
                itemCount: _posts.length,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pagination dots
          if (_posts.length > 1)
            SizedBox(
              height: 8,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _posts.length; i++)
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

  Widget _buildPostItem(LearningPostModel post) {
    return SizedBox(
      height: 318,
      width: _itemWidth,
      child: InkWell(
        onTap: () => _onPostTap(post),
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
              // Post image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: post.imageUrl.url,
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12.0),
              // Post content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post title
                      Text(
                        post.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          height: 24.0 / 15.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Category tag
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            R.drawable.ic_lesson_category,
                            width: 16.0,
                            height: 16.0,
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              'Bài học',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: R.color.color0xff666666,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
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

  void _onPostTap(LearningPostModel post) {
    if (post.enableLink && post.link != null) {
      _launchInBrowser(post.link!);
    } else {
      Navigator.pushNamed(
        context,
        NavigatorName.news_detail,
        arguments: {'id': post.id},
      );
    }
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
