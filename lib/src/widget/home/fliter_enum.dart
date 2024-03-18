import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum ScreenList {
  BLOOD_SUGAR,
  BLOOD_PRESSURE,
  WEIGHT,
  EMOTION,
  FOOD,
  EXERCISE,
  HBA1C
}

Map<String, int> valueOfSelectedFilter = {
  R.string.filter_day.tr(args: ['7']): 0,
  R.string.filter_day.tr(args: ['14']): 1,
  R.string.filter_day.tr(args: ['30']): 2,
  R.string.filter_day.tr(args: ['90']): 3,
  R.string.sau_thang.tr(): 0,
  R.string.mot_nam.tr(): 1,
  R.string.hai_nam.tr(): 2
};
