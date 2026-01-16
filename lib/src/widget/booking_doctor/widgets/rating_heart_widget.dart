import 'package:flutter/material.dart';

class RatingHeartWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double heartSize;
  final Color filledColor;
  final Color emptyColor;
  final double spacing;
  final bool showRatingText;
  final TextStyle? ratingTextStyle;

  const RatingHeartWidget({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.heartSize = 16.0,
    this.filledColor = const Color(0xFFFF6B6B),
    this.emptyColor = const Color(0xFFE0E0E0),
    this.spacing = 2.0,
    this.showRatingText = false,
    this.ratingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          return Padding(
            padding:
                EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
            child: _buildHeart(index + 1),
          );
        }),
        if (showRatingText) ...[
          SizedBox(width: spacing * 2),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeart(int position) {
    IconData heartIcon;
    Color heartColor;

    if (rating >= position) {
      // Full heart
      heartIcon = Icons.favorite;
      heartColor = filledColor;
    } else if (rating >= position - 0.5) {
      // Half heart
      heartIcon = Icons.favorite_border;
      heartColor = filledColor;
    } else {
      // Empty heart
      heartIcon = Icons.favorite_border;
      heartColor = emptyColor;
    }

    if (rating >= position - 0.5 && rating < position) {
      // Create half-filled heart
      return SizedBox(
        width: heartSize,
        height: heartSize,
        child: Stack(
          children: [
            Icon(
              Icons.favorite_border,
              size: heartSize,
              color: emptyColor,
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5,
                child: Icon(
                  Icons.favorite,
                  size: heartSize,
                  color: filledColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      heartIcon,
      size: heartSize,
      color: heartColor,
    );
  }
}

// Alternative heart widget with custom heart shape
class CustomRatingHeartWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double heartSize;
  final Color filledColor;
  final Color emptyColor;
  final double spacing;
  final bool showRatingText;
  final TextStyle? ratingTextStyle;

  const CustomRatingHeartWidget({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.heartSize = 16.0,
    this.filledColor = const Color(0xFFFF6B6B),
    this.emptyColor = const Color(0xFFE0E0E0),
    this.spacing = 2.0,
    this.showRatingText = false,
    this.ratingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          return Padding(
            padding:
                EdgeInsets.only(right: index < maxRating - 1 ? spacing : 0),
            child: _buildCustomHeart(index + 1),
          );
        }),
        if (showRatingText) ...[
          SizedBox(width: spacing * 2),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomHeart(int position) {
    double fillPercentage;

    if (rating >= position) {
      fillPercentage = 1.0;
    } else if (rating >= position - 1) {
      fillPercentage = rating - (position - 1);
    } else {
      fillPercentage = 0.0;
    }

    return SizedBox(
      width: heartSize,
      height: heartSize,
      child: CustomPaint(
        painter: HeartPainter(
          fillPercentage: fillPercentage,
          filledColor: filledColor,
          emptyColor: emptyColor,
        ),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final double fillPercentage;
  final Color filledColor;
  final Color emptyColor;

  HeartPainter({
    required this.fillPercentage,
    required this.filledColor,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    final path = _createHeartPath(size);

    // Draw empty heart
    paint.color = emptyColor;
    canvas.drawPath(path, paint);

    // Draw filled portion
    if (fillPercentage > 0) {
      canvas.save();
      canvas.clipRect(
          Rect.fromLTWH(0, 0, size.width * fillPercentage, size.height));
      paint.color = filledColor;
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Draw heart border
    paint
      ..color = emptyColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(path, paint);
  }

  Path _createHeartPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create heart shape
    path.moveTo(width * 0.5, height * 0.25);
    path.cubicTo(width * 0.2, height * 0.1, width * 0.1, height * 0.3,
        width * 0.15, height * 0.55);
    path.lineTo(width * 0.5, height * 0.9);
    path.lineTo(width * 0.85, height * 0.55);
    path.cubicTo(width * 0.9, height * 0.3, width * 0.8, height * 0.1,
        width * 0.5, height * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.filledColor != filledColor ||
        oldDelegate.emptyColor != emptyColor;
  }
}
