import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.audioPlayer,
    this.onComplete,
  });

  final AudioPlayer audioPlayer;
  final VoidCallback? onComplete;

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late String url;

  late AudioPlayer _audioPlayer;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  @override
  void initState() {
    super.initState();
    // url = widget.url;
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StreamBuilder<PlayerState>(
            initialData: PlayerState.STOPPED,
            stream: _audioPlayer.onPlayerStateChanged,
            builder: (context, snapshot) {
              final bool isPlaying = snapshot.data == PlayerState.PLAYING;
              return IconButton(
                onPressed: () {
                  isPlaying ? _pause() : _play();
                },
                icon: isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                iconSize: 24.sp,
              );
            }),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: R.style.normalTextStyle
        ),
        Expanded(
          child: Slider(
            inactiveColor: R.color.gray,
            activeColor: R.color.textDark,
            onChanged: (v) {
              final duration = _duration;
              if (duration == null) {
                return;
              }
              final double position = v * duration.inMilliseconds;
              _audioPlayer.seek(Duration(milliseconds: position.round()));
            },
            value: value,
          ),
        ),
      ],
    );
  }

  double get value {
    if (_position == null ||
        _duration == null ||
        _position!.inMilliseconds <= 0) return 0.0;
    if (_position!.inMilliseconds >= _duration!.inMilliseconds) return 1.0;
    return _position!.inMilliseconds / _duration!.inMilliseconds;
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // optional: listen for notification updates in the background
        _audioPlayer.notificationService.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.notificationService.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'Image URL or blank',
          forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          enableNextTrackButton: true,
          enablePreviousTrackButton: true,
        );
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _duration = const Duration();
        _position = const Duration();
      });
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) {}

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {}
    return result;
  }

  void _onComplete() {
    widget.onComplete?.call();
  }
}
