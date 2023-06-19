import 'package:flutter/material.dart';

class AppMediaQuery {
  static late double deviceHeight;
  static late double deviceWidth;
  static late double deviceStatusBar;
  static late double deviceSafeAreaTop;
  static late double devicePixelRatio;
  static late double deviceSafeAreaBottom;
  static late double deviceHeigthAvailable;
  static late double deviceHeigthBottomAppBar;

  init(context) {
    deviceSafeAreaTop = MediaQuery.of(context).padding.top;
    deviceSafeAreaBottom = MediaQuery.of(context).padding.bottom;
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceStatusBar = AppBar().preferredSize.height;
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    deviceHeigthAvailable = deviceHeight - deviceSafeAreaTop - deviceStatusBar;
    deviceHeigthBottomAppBar = 60;
  }
}
