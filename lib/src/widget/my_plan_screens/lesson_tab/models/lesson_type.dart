import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum LessonType {
  route,
  suggest,
}

extension LessonTypeDetail on LessonType {
  String get title {
    switch (this) {
      case LessonType.route:
        return R.string.title_route.tr();
      case LessonType.suggest:
      return R.string.title_suggest.tr();
    }
  }
}