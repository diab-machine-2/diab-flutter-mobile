import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
      useMaterial3: false,
      platform: TargetPlatform.iOS,
      primaryColor: R.color.white,
      indicatorColor: R.color.mainColor,
      appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          color: R.color.primaryColor,
          toolbarTextStyle: TextTheme(
                  titleLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: R.color.white))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: R.color.white))
              .titleLarge,
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      primaryIconTheme: IconThemeData(color: R.color.white),
      brightness: Brightness.light,
      colorScheme: ThemeData()
          .colorScheme
          .copyWith(primary: R.color.mainColor)
          .copyWith(secondary: R.color.mainColor));
}
