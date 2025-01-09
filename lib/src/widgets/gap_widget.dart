import 'package:flutter/material.dart';

class GapH extends StatelessWidget {
  final double height;

  const GapH(this.height, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class GapW extends StatelessWidget {
  final double width;

  const GapW(this.width, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
