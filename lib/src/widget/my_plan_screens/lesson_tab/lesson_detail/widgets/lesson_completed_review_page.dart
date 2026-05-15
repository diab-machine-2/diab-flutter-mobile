import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class LessonCompletedReviewPage extends StatefulWidget {
  const LessonCompletedReviewPage({
    Key? key,
    required this.moduleName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.note,
    required this.onShare,
  }) : super(key: key);

  final String moduleName;
  final String title;
  final String description;
  final String imageUrl;
  final int rating;
  final String note;
  final VoidCallback onShare;

  @override
  State<LessonCompletedReviewPage> createState() =>
      _LessonCompletedReviewPageState();
}

class _LessonCompletedReviewPageState extends State<LessonCompletedReviewPage> {
  // Use dynamic dispatch here to avoid analyzer issues in some build targets
  // where AppRepository API differs.
  final dynamic _repository = AppRepository();

  List<LessonSectionListResponseData>? _forYouLessons;
  bool _isForYouLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForYouLessons();
  }

  Future<void> _loadForYouLessons() async {
    setState(() => _isForYouLoading = true);
    final ApiResult<List<LessonSectionListResponseData>> apiResult =
        await (_repository.getRecommendedLessons()
            as Future<ApiResult<List<LessonSectionListResponseData>>>);

    apiResult.when(
      success: (List<LessonSectionListResponseData> response) {
        if (!mounted) return;
        setState(() {
          _forYouLessons = response;
          _isForYouLoading = false;
        });
      },
      failure: (_) {
        if (!mounted) return;
        setState(() {
          _forYouLessons = const [];
          _isForYouLoading = false;
        });
      },
    );
  }

  Widget _buildForYouSection(BuildContext context) {
    final lessons = _forYouLessons ?? const <LessonSectionListResponseData>[];
    if (!_isForYouLoading && lessons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              R.string.lesson_for_you.tr(),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_isForYouLoading)
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
            ...List.generate(
              lessons.length,
              (index) => _buildForYouLessonRow(
                lessonDetail: lessons[index],
                onTap: () {
                  final String? lessonId = lessons[index].id;
                  final int? lessonType = lessons[index].type;
                  if (lessonId == null || lessonId.isEmpty) return;
                  Navigator.pushNamed(
                    context,
                    NavigatorName.lesson_detail,
                    arguments: {
                      'lessonId': lessonId,
                      'lessonType': lessonType,
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForYouLessonRow({
    required LessonSectionListResponseData lessonDetail,
    VoidCallback? onTap,
  }) {
    final String module = lessonDetail.lessonModule?.name ?? '';
    final String imageUrl = lessonDetail.image?.url ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: NetWorkImageWidget(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
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
                    lessonDetail.name ?? '',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  LessonStatusWidget(
                    learningStatus: lessonDetail.learningStatus,
                    progress: lessonDetail.percentComplete,
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

  @override
  Widget build(BuildContext context) {
    final List<String> noteItems = widget.note
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final bool hasReview = widget.rating > 0 || noteItems.isNotEmpty;

    /// Pops this screen; the underlying [LessonDetailPage] then pops, returning
    /// to whichever tab (e.g. Program or Library) the user opened the lesson from.
    void onBack() {
      Navigator.of(context).pop(1);
    }

    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                R.color.greenGradientTop,
                R.color.greenGradientBottom,
              ],
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: R.color.white, size: 24),
              onPressed: onBack,
            ),
            Text(
              R.string.lesson_completed_title.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: R.color.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            R.string.lesson_completed_message.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: R.color.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (widget.imageUrl.isNotEmpty)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.imageUrl,
                                  width: 132,
                                  height: 86,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (widget.moduleName.isNotEmpty)
                            Text(
                              widget.moduleName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: R.color.greenGradientBottom,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: R.color.textDark,
                            ),
                          ),
                          if (widget.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: R.color.textDark,
                              ),
                            ),
                          ],
                          if (hasReview) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final bool isActive =
                                    (index + 1) <= widget.rating;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 24,
                                    color: isActive
                                        ? const Color(0xFFD9A93B)
                                        : const Color(0xFFD6DBDE),
                                  ),
                                );
                              }),
                            ),
                            if (widget.rating > 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.rating >= 4
                                    ? R.string.lesson_rating_useful.tr()
                                    : widget.rating == 3
                                        ? R.string.lesson_rating_normal.tr()
                                        : R.string.lesson_rating_not_useful
                                            .tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: R.color.textDark,
                                ),
                              ),
                            ],
                            if (noteItems.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: noteItems
                                    .map(
                                      (item) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF4F3),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: R.color.mainColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                          // const SizedBox(height: 14),
                          // SizedBox(
                          //   height: 46,
                          //   child: ElevatedButton(
                          //     onPressed: onBack,
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: const Color(0xFFC6ECEA),
                          //       foregroundColor: R.color.mainColor,
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(24),
                          //       ),
                          //     ),
                          //     child: Text(
                          //       'Hoàn thành',
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w700,
                          //         color: R.color.mainColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildForYouSection(context),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: R.color.white,
                boxShadow: [
                  BoxShadow(
                    color: R.color.textDark.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                MediaQuery.of(context).padding.bottom + 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC6ECEA),
                          foregroundColor: R.color.mainColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          R.string.lesson_back_to_library.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: widget.onShare,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: R.color.mainColor,
                          foregroundColor: R.color.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          R.string.share.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
