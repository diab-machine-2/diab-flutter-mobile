import 'package:medical/src/app_setting/app_setting.dart';
import 'package:meta/meta.dart';

class ComparerModel {
  final int date;
  final double preGlucose;
  final String preGlucoseColor;
  final double postGlucose;
  final String postGlucoseColor;
  final String description;

  ComparerModel({
    @required this.date,
    @required this.preGlucose,
    @required this.preGlucoseColor,
    @required this.postGlucose,
    @required this.postGlucoseColor,
    @required this.description,
  });
  @override
  factory ComparerModel.fromJson(Map<String, dynamic> json) {
    final unit = AppSettings.userInfo.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';
    return ComparerModel(
      date: json['date'],
      preGlucose: AppSettings.userInfo.glucoseUnit == 1
          ? json['preGlucose']
          : json['preGlucoseMmoll'],
      preGlucoseColor: json['preGlucoseColor'],
      postGlucose: AppSettings.userInfo.glucoseUnit == 1
          ? json['postGlucose']
          : json['postGlucoseMmoll'],
      postGlucoseColor: json['postGlucoseColor'],
      description: json['description'],
    );
  }

  static List<ComparerModel> toList(List<dynamic> items) {
    return items.map((item) => ComparerModel.fromJson(item)).toList();
  }
}
