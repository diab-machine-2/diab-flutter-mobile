import 'package:medical/modal/bmi/weight_input.dart';
import 'package:meta/meta.dart';

class InputWeightDataModel {
  final List<InputWeightModel> inputs;
  final bool hasMore;

  InputWeightDataModel({@required this.inputs, @required this.hasMore});
}
