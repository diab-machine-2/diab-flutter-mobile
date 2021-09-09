import 'package:medical/modal/blood_pressure/blood_pressure.dart';
import 'package:meta/meta.dart';

class BloodPressureDataModel {
  final List<BloodPressureModel> inputs;
  final bool hasMore;

  BloodPressureDataModel({@required this.inputs, @required this.hasMore});
}
