import 'package:medical/src/modal/bmi/weight_input.dart';
import 'package:meta/meta.dart';
@immutable
class InputWeightDataModel {
  final List<InputWeightModel> inputs;
  final bool? hasMore;

  const InputWeightDataModel({required this.inputs, required this.hasMore});
}
