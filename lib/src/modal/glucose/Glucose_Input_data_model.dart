import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:meta/meta.dart';
@immutable
class InputGlucoseDataModel {
  final List<InputGlucoseModel> inputs;
  final bool? hasMore;

  const InputGlucoseDataModel({required this.inputs, required this.hasMore});
}
