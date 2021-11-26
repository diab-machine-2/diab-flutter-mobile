import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:meta/meta.dart';
@immutable
class BloodPressureDataModel {
  final List<BloodPressureModel> inputs;
  final bool? hasMore;

  const BloodPressureDataModel({required this.inputs, required this.hasMore});
}
