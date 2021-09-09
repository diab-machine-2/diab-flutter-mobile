import 'package:medical/modal/glucose/glucose_input.dart';
import 'package:meta/meta.dart';

class InputGlucoseDataModel {
  final List<InputGlucoseModel> inputs;
  final bool hasMore;

  InputGlucoseDataModel({@required this.inputs, @required this.hasMore});
}
