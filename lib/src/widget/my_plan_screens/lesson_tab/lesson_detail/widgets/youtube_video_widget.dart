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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_isInitialized || !mounted) return;
    _isInitialized = true;

    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: ${widget.videoUrl}');
      }
      debugPrint('Video URL: ${widget.videoUrl}, Video ID: $videoId');

      // Fetch stream manifest
      final streamManifest =
          await _youtubeExplode.videos.streamsClient.getManifest(
        videoId,
        ytClients: [
          YoutubeApiClient.ios,
          YoutubeApiClient.android,
        ],
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Timed out fetching stream manifest');
      });

      // Fetch video metadata for duration
      final videoMetadata = await _youtubeExplode.videos.get(videoId);
      final videoDuration = videoMetadata.duration?.inSeconds;
      debugPrint(
          'Video metadata duration: ${videoDuration ?? 'unknown'} seconds');

      // Log available streams for debugging
      debugPrint('Muxed streams: ${streamManifest.muxed.length}');
      debugPrint('Video-only streams: ${streamManifest.videoOnly.length}');
      debugPrint('Audio-only streams: ${streamManifest.audioOnly.length}');

      // Select a muxed MP4 stream to ensure both video and audio
      final streamInfo = streamManifest.muxed
              .where((info) => info.container == StreamContainer.mp4)
              .firstOrNull ??
          streamManifest.muxed.first;
      if (streamInfo == null) {
        throw Exception('No suitable muxed stream found');
      }
      final streamUrl = streamInfo.url.toString();
      debugPrint(
          'Using muxed stream: $streamUrl (quality: ${streamInfo.videoQualityLabel})');

      _videoMetaData = {'videoId': videoId, 'duration': videoDuration};

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
          videoFormat:
              BetterPlayerVideoFormat.other, // Use 'other' for MP4 muxed stream
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
          if (event.betterPlayerEventType ==
              BetterPlayerEventType.initialized) {
            final duration = _controller!.videoPlayerController?.value.duration;
            debugPrint(
                'Player duration: ${duration?.inSeconds ?? 'unknown'} seconds');
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            widget.onPlay(meta: _videoMetaData);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            _controller!.exitFullScreen();
            await Future.delayed(const Duration(seconds: 1));
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
    _isInitialized = false;
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
                  _isInitialized = false;
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
