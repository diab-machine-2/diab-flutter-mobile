import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';

class CustomLoadMoreDelegate extends LoadMoreDelegate {
  const CustomLoadMoreDelegate();

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}) {
    if (status == LoadMoreStatus.idle || status == LoadMoreStatus.loading) {
      return SpinKitThreeBounce(color: R.color.mainColor, size: 20);
    } else {
      return Container(color: R.color.red);
    }
  }

  @override
  double widgetHeight(LoadMoreStatus status) {
    if (status == LoadMoreStatus.idle || status == LoadMoreStatus.loading) {
      return 40;
    } else {
      return 0;
    }
  }
}
