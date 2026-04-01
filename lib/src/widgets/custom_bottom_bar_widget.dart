import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';

double _progressFromPositionTitle(String title) {
  try {
    final parts = title.split('/');
    if (parts.length < 2) return 0;
    final cur = int.parse(parts[0].trim());
    final tot = int.parse(parts[1].trim());
    if (tot <= 0) return 0;
    return (cur / tot).clamp(0.0, 1.0);
  } catch (_) {
    return 0;
  }
}

class CustomBottomBarWidget extends StatelessWidget {
  CustomBottomBarWidget({
    required this.isPreviousButtonActive,
    required this.isNextButtonActive,
    required this.onTapPrevious,
    required this.onTapNext,
    required this.currentPositionTitle,
    this.onTapCenter,
    this.previousButtonTitle,
    this.nextButtonTitle,
    this.isCompleted,
  });

  final bool isPreviousButtonActive;
  final VoidCallback? onTapPrevious;
  final bool isNextButtonActive;
  final VoidCallback? onTapNext;
  final String currentPositionTitle;
  final VoidCallback? onTapCenter;
  final String? previousButtonTitle;
  final String? nextButtonTitle;
  bool? isCompleted;
  var userInfo = AppSettings.userInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.white,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row for buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              _buildPreviousButton(),
              SizedBox(width: 4),
              // Center button
              // _buildCenterButton(),
              // Expanded(
              //     child: Image.network(
              //         "https://res.cloudinary.com/dzgugrqxz/image/upload/v1716280100/xpripzukgihaokrhntzj.png")),
              if (AppSettings.isOwnPackage)
                _buildCenter()
              else
                _buildCenterButton(),
              SizedBox(width: 4),
              // Next button
              _buildNextButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenter() {
    final logoUrl = AppSettings.userInfo?.ownPackage?.logo ?? '';

    return InkWell(
      onTap: onTapCenter,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (logoUrl.isNotEmpty)
            //   Image.network(
            //     logoUrl,
            //     height: 30,
            //     errorBuilder: (context, error, stackTrace) {
            //       return const SizedBox(height: 50);
            //     },
            //   ),
            // if (logoUrl.isNotEmpty) const SizedBox(height: 10),
            _DonutStepProgress(
              currentPositionTitle: currentPositionTitle,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: R.color.mainColor,
                height: 1,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousButton() {
    final bool isInactive = isPreviousButtonActive;

    return InkWell(
      onTap: isInactive ? null : onTapPrevious,
      child: Container(
        width: 148,
        height: 44,
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isInactive ? R.color.color0xffEAEDEE : R.color.white,
          border: isInactive ? null : Border.all(color: R.color.mainColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: isInactive ? R.color.color0xff5E6566 : R.color.mainColor,
            ),
            Text(
              previousButtonTitle ?? R.string.back.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      isInactive ? R.color.color0xff5E6566 : R.color.mainColor,
                  // height: 1.43,
                  letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Expanded(
      child: InkWell(
        onTap: onTapCenter,
        borderRadius: BorderRadius.circular(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: _DonutStepProgress(
              currentPositionTitle: currentPositionTitle,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: R.color.mainColor,
                height: 1,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    if (isCompleted != null) {
      final bool canComplete = isCompleted!;
      return InkWell(
        onTap: canComplete ? onTapNext : null,
        child: Container(
          width: 148,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: canComplete
                ? R.color.greenGradientBottom
                : R.color.color0xffEAEDEE,
          ),
          alignment: Alignment.center,
          child: Text(
            R.string.complete_lesson.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: canComplete ? R.color.white : R.color.color0xff5E6566,
            ),
          ),
        ),
      );
    }
    return InkWell(
      onTap: isNextButtonActive ? onTapNext : null,
      child: Container(
        width: 148,
        height: 44,
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isNextButtonActive ? R.color.white : R.color.color0xffEAEDEE,
          border:
              isNextButtonActive ? Border.all(color: R.color.mainColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nextButtonTitle ?? R.string.next_lesson.tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNextButtonActive
                      ? R.color.mainColor
                      : R.color.color0xff5E6566,
                  // height: 1.43,
                  letterSpacing: 0.4),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isNextButtonActive
                  ? R.color.mainColor
                  : R.color.color0xff5E6566,
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal donut ring: track [R.color.color0xffDADEDF], progress [R.color.mainColor].
class _DonutStepProgress extends StatelessWidget {
  const _DonutStepProgress({
    required this.currentPositionTitle,
    this.size = 44,
    this.strokeWidth = 3,
    required this.labelStyle,
  });

  final String currentPositionTitle;
  final double size;
  final double strokeWidth;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final progress = _progressFromPositionTitle(currentPositionTitle);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutRingPainter(
              progress: progress,
              trackColor: R.color.color0xffDADEDF,
              progressColor: R.color.mainColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Text(
            currentPositionTitle,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}

class _DonutRingPainter extends CustomPainter {
  _DonutRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    canvas.drawArc(rect, start, math.pi * 2, false, trackPaint);

    final sweep = math.pi * 2 * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(rect, start, sweep, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
