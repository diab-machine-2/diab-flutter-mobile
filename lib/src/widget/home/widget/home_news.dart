import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../schema/home_schema.dart';

class HomeNews extends StatelessWidget {
  const HomeNews({
    super.key,
    required this.items,
    required this.onViewMore,
    required this.onNewsTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final List<HomeNewsData> items;

  final VoidCallback onViewMore;
  final Function(HomeNewsData) onNewsTap;
  final Function(HomeNewsData) onLike;
  final Function(HomeNewsData) onComment;
  final Function(HomeNewsData) onShare;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4.0),
          // Header
          Row(
            children: [
              const SizedBox(width: 16.0),
              Text(
                "Tin nổi bật",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: R.color.color0xff27272A,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: R.color.greenGradientBottom,
                  ),
                ),
                onPressed: onViewMore,
                child: Text("Xem thêm"),
              ),
              const SizedBox(width: 16.0),
            ],
          ),

          const SizedBox(height: 6.0),

          // News
          SizedBox(
            height: 320.0,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: items.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final lesson = items[index];
                return _buildNewsItem(lesson);
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: 12.0);
              },
            ),
          ),

          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildNewsItem(HomeNewsData news) {
    return InkWell(
      onTap: () => onNewsTap(news),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 320.0,
        width: 338.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            // https://picsum.photos/654/348
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: NetWorkImageWidget(
                imageUrl: news.imageUrl,
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
                      news.title,
                      maxLines: 2,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 15.0,
                        height: 24.0 / 15.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Image.asset(
                          news.icon,
                          width: 16.0,
                          height: 16.0,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          news.category,
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

            // Actions
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 16.0),

                // Like
                InkWell(
                  onTap: () => onLike(news),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_like, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "${news.likeCount}",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16.0),

                // Comment
                InkWell(
                  onTap: () => onComment(news),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_comment, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "${news.commentCount}",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share
                InkWell(
                  onTap: () => onShare(news),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_lesson_share, width: 20.0, height: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        "Chia sẻ",
                        style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16.0),
              ],
            ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
