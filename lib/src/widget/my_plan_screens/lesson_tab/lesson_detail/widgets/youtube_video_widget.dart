import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:medical/res/R.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final Function({dynamic meta}) onEnded;
  final Function({dynamic meta}) onPlay;
  final String? videoTitle;
  final String? videoArtist;
  final String? videoThumbnail;

  const YoutubeVideoWidget({
    Key? key,
    required this.videoUrl,
    required this.onEnded,
    required this.onPlay,
    this.videoTitle,
    this.videoArtist,
    this.videoThumbnail,
  }) : super(key: key);

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget>
    with WidgetsBindingObserver {
  BetterPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  dynamic _videoMetaData;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;

    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ??
          widget.videoUrl.split('/').last;
      final streamManifest =
          await _youtubeExplode.videos.streamsClient.getManifest(videoId);
      final streamInfo = streamManifest.muxed.bestQuality;
      final streamUrl = streamInfo.url.toString();

      _videoMetaData = {'videoId': videoId};

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          handleLifecycle: true,
          allowedScreenSleep: false,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
          autoDispose: false,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          systemOverlaysAfterFullScreen: [
            SystemUiOverlay.top,
            SystemUiOverlay.bottom,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableProgressText: true,
            enableProgressBar: true,
            enablePlayPause: true,
            enableMute: true,
            enableFullscreen: true,
            enableSubtitles: false,
            enableAudioTracks: false,
            enableOverflowMenu: true,
            enablePlaybackSpeed: true,
            progressBarPlayedColor: R.color.greenGradientBottom,
            progressBarHandleColor: R.color.greenGradientBottom,
          ),
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: Image.asset(
                R.drawable.ic_thumbnail1,
                fit: BoxFit.cover,
              ),
            ),
          ),
          showPlaceholderUntilPlay: true,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          streamUrl,
          videoFormat: BetterPlayerVideoFormat.other,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.videoTitle ?? 'DiaB Lesson',
            author: widget.videoArtist ?? 'DiaB',
            imageUrl: widget.videoThumbnail ?? R.drawable.ic_app,
          ),
          headers: {
            'User-Agent': 'diaB Video Player',
          },
        ),
      );

      _controller!.addEventsListener((event) async {
        if (mounted) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play &&
              !_controller!.isPlaying()!) {
            widget.onPlay(meta: _videoMetaData);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            widget.onEnded(meta: _videoMetaData);
          }
        }
      });

      await _controller!.setupDataSource(_controller!.betterPlayerDataSource!);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing YouTube video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('YouTube: App paused/inactive - keeping audio playing');
        break;
      case AppLifecycleState.resumed:
        debugPrint('YouTube: App resumed');
        break;
      case AppLifecycleState.detached:
        _controller?.pause();
        break;
      default:
        break;
    }
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose(forceDispose: true);
    _youtubeExplode.close();
    super.dispose();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load YouTube video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _initializePlayer();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _controller!),
    );
  }
}
