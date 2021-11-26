import 'package:medical/src/modal/bmi/bmi_input.dart';
import 'package:meta/meta.dart';
@immutable
class InputBmiDataModel {
  final List<InputBmiModel> inputs;
  final bool hasMore;

  const InputBmiDataModel({required this.inputs, required this.hasMore});
}
