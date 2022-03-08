import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/images.dart';

class HomeModel {
  final GloucoseIndexModel glucoseIndex;
  final BloodPressureIndexModel bloodPressureIndex;
  final WeightCardModel? weightCard;
  final EmotionCardModel? emotionCard;
  final EnergyCardModel? energyCard;
  final ExerciseIndexModel? exercise;
  final HbA1CIndexModel hbA1CIndex;
  final EnergyExerciseCardModel? energyExerciseCard;
  final ProcessCardModel? processCard;
  final bool isDisplayedWelcome;

  HomeModel({
    required this.glucoseIndex,
    required this.bloodPressureIndex,
    required this.exercise,
    required this.hbA1CIndex,
    required this.weightCard,
    required this.emotionCard,
    required this.energyCard,
    required this.energyExerciseCard,
    required this.processCard,
    required this.isDisplayedWelcome,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      glucoseIndex: GloucoseIndexModel.fromJson(json['glucoseIndex']),
      bloodPressureIndex: BloodPressureIndexModel.fromJson(json['bloodPressureIndex']),
      exercise: json['exercise'] == null ? null : ExerciseIndexModel.fromJson(json['exercise']),
      hbA1CIndex: HbA1CIndexModel.fromJson(json['hbA1CIndex']),
      weightCard: json['weightCard'] == null ? null : WeightCardModel.fromJson(json['weightCard']),
      emotionCard: json['emotionCard'] == null ? null : EmotionCardModel.fromJson(json['emotionCard']),
      energyCard: json['energyCard'] == null ? null : EnergyCardModel.fromJson(json['energyCard']),
      energyExerciseCard: json['energyExerciseCard'] == null
          ? null
          : EnergyExerciseCardModel.fromJson(
              json['energyExerciseCard'],
            ),
      processCard: json['processCard'] == null ? null : ProcessCardModel.fromJson(json['processCard']),
      isDisplayedWelcome: json['isDisplayedWelcome'] ?? false,
    );
  }

  static List<HomeModel> toList(List<dynamic> items) {
    return items.map((item) => HomeModel.fromJson(item)).toList();
  }
}

class GloucoseIndexModel {
  final double? index;
  final double? indexChange;
  final String unit;
  final int? createDateTime;
  final String? color;
  final ImagesModel? icon;

  GloucoseIndexModel(
      {required this.index,
      required this.indexChange,
      required this.unit,
      required this.createDateTime,
      required this.color,
      required this.icon});

  factory GloucoseIndexModel.fromJson(Map<String, dynamic> json) {
    final unit = AppSettings.userInfo!.glucoseUnit == 1 ? R.string.mg_dl.tr() : R.string.mmol_l.tr();
    return GloucoseIndexModel(
      index: AppSettings.userInfo!.glucoseUnit == 1 ? json['index'] : json['indexMmoll'],
      indexChange: AppSettings.userInfo!.glucoseUnit == 1 ? json['indexChange'] : json['indexChangeMmoll'],
      unit: unit,
      createDateTime: json['createDateTime'],
      color: json['color'],
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
    );
  }

  static List<GloucoseIndexModel> toList(List<dynamic> items) {
    return items.map((item) => GloucoseIndexModel.fromJson(item)).toList();
  }
}

class BloodPressureIndexModel {
  final double? systolic;
  final double? systolicChange;
  final double? diastolic;
  final double? diastolicChange;
  final String? color;
  final ImagesModel? icon;
  final int? createDateTime;

  BloodPressureIndexModel(
      {required this.systolic,
      required this.systolicChange,
      required this.diastolic,
      required this.diastolicChange,
      required this.color,
      required this.icon,
      required this.createDateTime});

  factory BloodPressureIndexModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureIndexModel(
      systolic: json['systolic'],
      systolicChange: json['systolicChange'],
      diastolic: json['diastolic'],
      diastolicChange: json['diastolicChange'],
      color: json['color'],
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
      createDateTime: json['createDateTime'],
    );
  }

  static List<BloodPressureIndexModel> toList(List<dynamic> items) {
    return items.map((item) => BloodPressureIndexModel.fromJson(item)).toList();
  }
}

class ExerciseIndexModel {
  final double? index;
  final double? indexChange;
  final double? facExercise;
  final double? targetExercise;
  final String? unit;
  final int? createDateTime;
  final String? color;
  final ImagesModel? icon;

  ExerciseIndexModel(
      {required this.index,
      required this.indexChange,
      required this.facExercise,
      required this.targetExercise,
      required this.unit,
      required this.createDateTime,
      required this.color,
      required this.icon});

  factory ExerciseIndexModel.fromJson(Map<String, dynamic> json) {
    return ExerciseIndexModel(
      index: json['index'],
      indexChange: json['indexChange'],
      facExercise: json['facExercise'] ?? 0,
      targetExercise: json['targetExercise'] ?? 0,
      unit: json['unit'],
      createDateTime: json['createDateTime'],
      color: json['color'],
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
    );
  }

  static List<ExerciseIndexModel> toList(List<dynamic> items) {
    return items.map((item) => ExerciseIndexModel.fromJson(item)).toList();
  }
}

class HbA1CIndexModel {
  final double? index;
  final double? indexChange;
  final int? createDateTime;
  final String? color;
  final ImagesModel? icon;

  HbA1CIndexModel(
      {required this.index,
      required this.indexChange,
      required this.createDateTime,
      required this.color,
      required this.icon});

  factory HbA1CIndexModel.fromJson(Map<String, dynamic> json) {
    return HbA1CIndexModel(
      index: json['index'],
      indexChange: json['indexChange'],
      createDateTime: json['createDateTime'],
      color: json['color'],
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
    );
  }

  static List<HbA1CIndexModel> toList(List<dynamic> items) {
    return items.map((item) => HbA1CIndexModel.fromJson(item)).toList();
  }
}

class WeightCardModel {
  final double? weight;
  final double? goalWeight;
  final int? weightDateTime;
  final String? weightColorCode;

  WeightCardModel(
      {required this.weight, required this.goalWeight, required this.weightDateTime, required this.weightColorCode});

  factory WeightCardModel.fromJson(Map<String, dynamic> json) {
    return WeightCardModel(
        weight: json['weight'],
        goalWeight: json['goalWeight'],
        weightDateTime: json['weightDateTime'],
        weightColorCode: json['weightColorCode']);
  }

  static List<WeightCardModel> toList(List<dynamic> items) {
    return items.map((item) => WeightCardModel.fromJson(item)).toList();
  }
}

class EmotionCardModel {
  final int? emotionDateTime;
  final List<EmotionCardItemModel>? details;

  EmotionCardModel({required this.emotionDateTime, required this.details});

  factory EmotionCardModel.fromJson(Map<String, dynamic> json) {
    return EmotionCardModel(
      emotionDateTime: json['emotionDateTime'],
      details: json['details'] == null ? null : EmotionCardItemModel.toList(json['details']),
    );
  }

  static List<EmotionCardModel> toList(List<dynamic> items) {
    return items.map((item) => EmotionCardModel.fromJson(item)).toList();
  }
}

class EmotionCardItemModel {
  final String? text;
  final ImagesModel? icon;

  EmotionCardItemModel({required this.text, required this.icon});

  factory EmotionCardItemModel.fromJson(Map<String, dynamic> json) {
    return EmotionCardItemModel(
      text: json['text'],
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
    );
  }

  static List<EmotionCardItemModel> toList(List<dynamic> items) {
    return items.map((item) => EmotionCardItemModel.fromJson(item)).toList();
  }
}

class EnergyCardModel {
  final int? consumedEnergyDateTime;
  final double? consumedEnergy;
  final ImagesModel? energyIcon;

  EnergyCardModel({required this.consumedEnergyDateTime, required this.consumedEnergy, required this.energyIcon});

  factory EnergyCardModel.fromJson(Map<String, dynamic> json) {
    return EnergyCardModel(
      consumedEnergyDateTime: json['consumedEnergyDateTime'],
      consumedEnergy: json['consumedEnergy'],
      energyIcon: json['energyIcon'] == null ? null : ImagesModel.fromJson(json['energyIcon']),
    );
  }

  static List<EnergyCardModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyCardModel.fromJson(item)).toList();
  }
}

class EnergyExerciseCardModel {
  final double? value;
  final double? energyGoal;
  final String? text;
  final String? corlorCode;

  EnergyExerciseCardModel(
      {required this.value, required this.energyGoal, required this.text, required this.corlorCode});

  factory EnergyExerciseCardModel.fromJson(Map<String, dynamic> json) {
    return EnergyExerciseCardModel(
        value: json['value'], energyGoal: json['energyGoal'], text: json['text'], corlorCode: json['corlorCode']);
  }

  static List<EnergyExerciseCardModel> toList(List<dynamic> items) {
    return items.map((item) => EnergyExerciseCardModel.fromJson(item)).toList();
  }
}

class ProcessCardModel {
  final int? target;
  final int? targetCompeleted;
  final int? exerciseCompeleted;
  final int? exercise;
  final int? lessonCompeleted;
  final bool? userFree;
  final int? createDateTime;
  final String? color;
  final ImagesModel? icon;

  ProcessCardModel({
    required this.target,
    required this.targetCompeleted,
    required this.exerciseCompeleted,
    required this.exercise,
    required this.lessonCompeleted,
    required this.userFree,
    required this.createDateTime,
    required this.color,
    required this.icon,
  });

  factory ProcessCardModel.fromJson(Map<String, dynamic> json) {
    return ProcessCardModel(
      target: json['target'] ?? 0,
      targetCompeleted: json['targetCompeleted'] ?? 0,
      exerciseCompeleted: json['exerciseCompeleted'] ?? 0,
      exercise: json['exercise'] ?? 0,
      lessonCompeleted: json['lessonCompeleted'] ?? 0,
      userFree: json['userFree'] ?? true,
      createDateTime: json['createDateTime'] ?? 0,
      color: json['color'] ?? '',
      icon: json['icon'] == null ? null : ImagesModel.fromJson(json['icon']),
    );
  }

  static List<ProcessCardModel> toList(List<dynamic> items) {
    return items.map((item) => ProcessCardModel.fromJson(item)).toList();
  }
}
