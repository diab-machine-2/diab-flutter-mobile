import 'package:flutter/material.dart';

class SpacingRow extends Flex {
  SpacingRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    double spacing = 0,
    bool isSpacingHeadTale = false,
    Widget? separator,
  }) : super(
          children: [
            if (isSpacingHeadTale) SizedBox(height: spacing),
            ...children.addBetweenEvery(
              Column(
                crossAxisAlignment: crossAxisAlignment,
                children: <Widget>[
                  SizedBox(width: spacing / 2),
                  separator ?? const SizedBox.shrink(),
                  SizedBox(width: spacing / 2),
                ],
              ),
            ),
            if (isSpacingHeadTale) SizedBox(width: spacing),
          ],
          key: key,
          direction: Axis.horizontal,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );
}

class SpacingColumn extends Flex {
  SpacingColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    double spacing = 0,
    bool isSpacingHeadTale = false,
    Widget? separator,
  }) : super(
          children: [
            if (isSpacingHeadTale) SizedBox(height: spacing),
            ...children.addBetweenEvery(
              Column(
                children: <Widget>[
                  SizedBox(height: spacing / 2),
                  separator ?? const SizedBox.shrink(),
                  SizedBox(height: spacing / 2),
                ],
              ),
            ),
            if (isSpacingHeadTale) SizedBox(height: spacing),
          ],
          key: key,
          direction: Axis.vertical,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );
}

extension ListExt on List {}

extension ListExtension<T> on List<T> {
  List<T> addBetweenEvery(T value) {
    List<T> r = [];
    asMap().forEach((i, e) => i < length - 1 ? r.addAll([e, value]) : r.add(e));
    return r;
  }

  bool get isExistAndNotEmpty => isNotEmpty;
}
