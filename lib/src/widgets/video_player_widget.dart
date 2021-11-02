import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/common_page.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({required this.title, required this.videoUrl});
  final String title;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        //TODO: Change background
        background: R.drawable.bg_lesson_detail,
        title: title,
        showCloseBackButton: true,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: BetterPlayer.network(videoUrl)),
          ],
        ),
      ),
    );
  }
}
