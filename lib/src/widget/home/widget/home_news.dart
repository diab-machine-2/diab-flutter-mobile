import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/home/home_mock.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

typedef OnNewsTap = void Function(LearningPostModel news);

/// Home "Sự kiện & Tin nổi bật" carousel (Figma 22514:9701): event cards and
/// news cards from `LearningPost/Active`, in backend order.
class HomeNews extends StatelessWidget {
  const HomeNews({
    super.key,
    required this.items,
    required this.onNewsTap,
  });

  static const double cardWidth = 303;
  static const double imageHeight = 190;

  final List<LearningPostModel> items;
  final OnNewsTap onNewsTap;

  /// A webinar/event post: a real host account plus `eventType`
  /// (true = offline, false = online). Same rule the old banner tap used, and
  /// shared with Home's tap handler so card look and tap target agree.
  static bool isEvent(LearningPostModel post) {
    final accountId = post.accountId;
    return accountId != null &&
        accountId.isNotEmpty &&
        accountId != '00000000-0000-0000-0000-000000000000' &&
        post.eventType != null;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: R.color.homeCardShadow,
            offset: const Offset(1, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              R.string.home_news_title.tr(),
              style: TextStyle(
                color: R.color.color0xff111515,
                fontSize: 18,
                height: 1.32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _buildCard(items[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(LearningPostModel post) {
    final event = isEvent(post);
    return SizedBox(
      width: cardWidth,
      child: Material(
        color: R.color.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: R.color.color0xffDADEDF),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onNewsTap(post),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tight box: IntrinsicHeight must not reach the image widget's
              // LayoutBuilder (which can't report intrinsic sizes).
              SizedBox(
                width: cardWidth,
                height: imageHeight,
                child: NetWorkImageWidget(
                  // Banner-only posts may only carry the banner image.
                  imageUrl: post.imageUrl.url?.isNotEmpty == true
                      ? post.imageUrl.url
                      : post.imageBannerUrl?.url,
                  fit: BoxFit.cover,
                  height: imageHeight,
                  width: cardWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: event ? _eventLines(post) : _newsLines(post),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _eventLines(LearningPostModel post) {
    final when = _eventWhen(post);
    final online = post.eventType == false;
    final place = online
        ? R.string.home_event_online.tr()
        : (post.eventAddress?.trim() ?? '');
    return [
      if (when.isNotEmpty) ...[
        Text(when, style: _metaStyle(15)),
        const SizedBox(height: 8),
      ],
      _title(post.title),
      if (place.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(
          children: [
            online
                ? Icon(Icons.videocam_outlined,
                    size: 16, color: R.color.color0xff5E6566)
                : SvgPicture.asset(R.icons.ic_home_map_pin,
                    width: 14, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _metaStyle(15),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _newsLines(LearningPostModel post) {
    final date = formatDate(post.createDatetime);
    return [
      if (date.isNotEmpty) ...[
        Text(R.string.home_news_tag.tr(args: [date]), style: _metaStyle(15)),
        const SizedBox(height: 8),
      ],
      _title(post.title),
      // BE-4: reading time / view count aren't served yet; sample values only
      // with HOME_MOCK.
      if (HomeMock.enabled) ...[
        const SizedBox(height: 8),
        Text(
          '${R.string.home_news_reading_time.tr(args: [
                '${HomeMock.readingMinutes(post.id)}'
              ])}'
          ' · '
          '${R.string.home_news_view_count.tr(args: [
                NumberFormat.compact().format(HomeMock.viewCount(post.id))
              ])}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _metaStyle(12).copyWith(letterSpacing: 0.2, height: 1.5),
        ),
      ],
    ];
  }

  Widget _title(String title) => Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: R.color.color0xff111515,
          fontSize: 15,
          height: 1.46,
          fontWeight: FontWeight.w700,
        ),
      );

  TextStyle _metaStyle(double size) => TextStyle(
        color: R.color.color0xff5E6566,
        fontSize: size,
        height: 1.46,
        letterSpacing: 0.4,
      );

  /// "14:54 Thứ 3, 12/04/2025" (time left out when the event has none).
  static String _eventWhen(LearningPostModel post) {
    final date = post.eventDate;
    if (date == null || date == 0) return '';
    final day = DateTime.fromMillisecondsSinceEpoch(date * 1000).toLocal();
    final dayText =
        '${getWeekDay(date)}, ${DateFormat('dd/MM/yyyy').format(day)}';
    final parts = (post.eventTime ?? '').split(':');
    if (parts.length < 2) return dayText;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return dayText;
    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return '$time $dayText';
  }

  /// `createDatetime` comes as "04/03/2026 14:10:44" from
  /// `LearningPost?Position=`; epoch seconds and ISO strings are accepted
  /// too. Unparseable → no date.
  @visibleForTesting
  static String formatDate(String raw) {
    final value = raw.trim();
    final seconds = int.tryParse(value);
    final parsed = seconds != null
        ? DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toLocal()
        : DateTime.tryParse(value)?.toLocal() ?? _parseDayFirst(value);
    if (parsed == null) return '';
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  static DateTime? _parseDayFirst(String value) {
    for (final pattern in const ['dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy']) {
      try {
        return DateFormat(pattern).parseStrict(value);
      } on FormatException {
        // Try the next pattern.
      }
    }
    return null;
  }
}
