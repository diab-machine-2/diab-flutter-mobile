import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

class HbA1cHelpSection extends StatefulWidget {
  const HbA1cHelpSection({Key? key}) : super(key: key);

  @override
  State<HbA1cHelpSection> createState() => _HbA1cHelpSectionState();
}

class _HbA1cHelpSectionState extends State<HbA1cHelpSection> {
  final List<LessonModel> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      setState(() => _isLoading = true);
      _lessons.clear();
      final lessons = await HbA1CClient().fetchHbA1CLessons();
      if (mounted) {
        setState(() {
          _lessons.addAll(lessons);
          _isLoading = false;
        });
      }
    } catch (e, s) {
      print('❌ Error loading HbA1C help lessons: $e');
      TrackingManager.recordError(e, s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLessonDetail(LessonModel lesson) async {
    ActivityListTracking.clickLessonItem(
      objectId: lesson.id,
      objectIndex: null,
      objectTitle: lesson.name,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lesson.type,
        lessonId: lesson.id,
        onComplete: (_, __) {},
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            "Bạn cần hỗ trợ gì?",
            style: TextStyle(
              fontSize: 18,
              fontFamily: R.font.sfpro,
              fontWeight: FontWeight.w700,
              height: 24 / 18,
              letterSpacing: 0.2,
              color: R.color.dark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _isLoading
            ? _buildLoadingState()
            : _lessons.isEmpty
                ? const SizedBox()
                : _buildLessonsGrid(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 312, // 2 rows * (152 + 8)
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(R.color.mainColor),
        ),
      ),
    );
  }

  Widget _buildLessonsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1 / 1,
      ),
      itemBuilder: (context, index) => _buildLessonItem(_lessons[index]),
      itemCount: _lessons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson),
      child: Container(
        decoration: R.decorationStyle.mediumRadiusCardStyles,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.mediumRadius),
                  topRight: Radius.circular(AppDimens.mediumRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(lesson) ?? "",
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.neutral5,
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 56,
                      color: AppColors.neutral4,
                    ),
                  ),
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                lesson.name,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
