import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
      platform: TargetPlatform.iOS,
      primaryColor: R.color.white,
      indicatorColor: R.color.mainColor,
      accentColor: R.color.mainColor,
      colorScheme: ThemeData().colorScheme.copyWith(primary: R.color.mainColor),
      appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          color: R.color.primaryColor,
          brightness: Brightness.light,
          textTheme: TextTheme(
              headline6: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: R.color.white))),
      primaryIconTheme: IconThemeData(color: R.color.white),
      brightness: Brightness.light);
}
