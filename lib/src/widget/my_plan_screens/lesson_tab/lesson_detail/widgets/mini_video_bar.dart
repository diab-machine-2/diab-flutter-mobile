import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

/// Mini bar floating ở dưới màn hình — kết nối trực tiếp với
/// BetterPlayerController của video đang phát.
class MiniVideoBar extends StatefulWidget {
  const MiniVideoBar({
    Key? key,
    required this.videoController,
  }) : super(key: key);

  final BetterPlayerController videoController;

  @override
  State<MiniVideoBar> createState() => _MiniVideoBarState();
}

class _MiniVideoBarState extends State<MiniVideoBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Lắng nghe update vị trí mỗi 500ms
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final vp = widget.videoController.videoPlayerController;
    if (vp == null || !vp.value.initialized) {
      return const SizedBox.shrink();
    }

    final position = vp.value.position;
    final duration = vp.value.duration ?? Duration.zero;
    final isPlaying = vp.value.isPlaying;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play / Pause — outlined teal circle
          GestureDetector(
            onTap: () {
              if (isPlaying) {
                widget.videoController.pause();
              } else {
                widget.videoController.play();
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: R.color.greenGradientBottom,
                  width: 2,
                ),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 18,
                color: R.color.greenGradientBottom,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Time
          Text(
            '${_format(position)} / ${_format(duration)}',
            style: TextStyle(
              fontSize: 13,
              color: R.color.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),

          // Thin progress line
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 0,
                ),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                inactiveColor: const Color(0xFFD0D0D0),
                activeColor: R.color.greenGradientBottom,
                value: progress,
                onChanged: (v) {
                  final newPos = Duration(
                    milliseconds: (v * duration.inMilliseconds).toInt(),
                  );
                  widget.videoController.seekTo(newPos);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
