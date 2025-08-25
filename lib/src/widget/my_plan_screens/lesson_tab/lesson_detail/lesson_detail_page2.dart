import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LessonDetailPage2 extends StatefulWidget {
  final Function(String, int) onComplete;
  final SmartGoalList? smartGoal;

  const LessonDetailPage2({
    required this.lessonType,
    required this.lessonId,
    required this.onComplete,
    this.smartGoal,
  });

  final int? lessonType;
  final String lessonId;

  @override
  _LessonDetailPageState2 createState() => _LessonDetailPageState2();
}

class _LessonDetailPageState2 extends State<LessonDetailPage2> {
  BetterPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    try {
      var yt = YoutubeExplode();
      var videoId = VideoId("https://www.youtube.com/watch?v=bq1mcfOgU70");

      final manifest = await yt.videos.streamsClient.getManifest(videoId);

      // thử lấy muxed trước
      var muxedList = manifest.muxed.toList();

      String? streamUrl;

      if (muxedList.isNotEmpty) {
        // có muxed stream, dùng luôn
        var streamInfo = muxedList.firstWhere(
              (element) => element.tag == 18,
          orElse: () => muxedList.first,
        );
        streamUrl = streamInfo.url.toString();
      } else {
        // không có muxed, fallback sang adaptive video
        var videoStream = manifest.video.withHighestBitrate();
        streamUrl = videoStream.url.toString();

        debugPrint("Không có muxed, phải ghép audio và video: $streamUrl");
      }

      if (streamUrl != null) {
        setState(() {
          _controller = BetterPlayerController(
            BetterPlayerConfiguration(
              autoPlay: true,
              aspectRatio: 16 / 9,
            ),
            betterPlayerDataSource: BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              streamUrl!,
            ),
          );
        });
      }
    } catch (e, s) {
      debugPrint("Lỗi khi load video: $e\n$s");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test")),
      body: Center(
        child: _controller != null
            ? AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _controller!),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
