import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
      platform: TargetPlatform.iOS,
      primaryColor: Colors.white,
      indicatorColor: mainColor,
      accentColor: mainColor,
      appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          color: primaryColor,
          brightness: Brightness.light,
          textTheme: TextTheme(
              headline6: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))),
      primaryIconTheme: IconThemeData(color: Colors.white),
      brightness: Brightness.light);
}

Color primaryColor = Color(0xFF226BCC);
Color backgroundColor = Color(0xFFf2f2f4);
Color primaryGreyColor = Color(0xff666666);
Color primaryLightGreyColor = Colors.grey[200];
Color textDark = Color(0xff0A2836);
Color captionColorGray = Color(0xff9C9C9C);
Color statusGood = Color(0xff7CB5FF);
Color statusAverage = Color(0xffFC9E54);
Color grayBorder = Color(0xffE2E4E7);
Color grayComponentBorder = Color(0xffDDDDDD);
Color blueText = Color(0xff004D84);
Color mainColor = Color(0xff01645A);
Color notActiveGreen = Color(0xff7EC8C3);
Color yellow = Color(0xffFDB913);
Color green = Color(0xff21A567);
Color greenLight = Color(0xff9CD9B8);
Color redLight = Color(0xffFFCDD2);
Color red = Color(0xffE53935);
Color greenbg = Color(0xffE6F6ED);
Color grayCaption = Color(0xff9C9C9C);
Color greenGradientTop = Color(0xff4BB2AB);
Color greenGradientBottom = Color(0xff008479);
