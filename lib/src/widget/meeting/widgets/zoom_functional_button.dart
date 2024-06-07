import 'package:flutter/material.dart';

/// A button with imaeg-icon and text, orderer vertically.
class ZoomFunctionalButton extends StatelessWidget {
  const ZoomFunctionalButton({
    super.key,
    required this.assetPath,
    required this.labelText,
    required this.labelColor,
    this.iconSize = 48.0,
    this.onPressed,
  });

  final String assetPath;
  final String labelText;
  final Color labelColor;
  final double iconSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 3.0),
          // Icon
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              width: iconSize,
              height: iconSize,
            ),
          ),
          const SizedBox(height: 4.0),
          // Text
          Text(
            labelText,
            style: TextStyle(
              color: labelColor,
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              height: 16.0 / 11.0,
            ),
          ),
        ],
      ),
    );
  }
}
