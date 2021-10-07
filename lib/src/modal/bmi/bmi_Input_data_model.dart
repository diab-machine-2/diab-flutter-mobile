import 'package:medical/src/modal/bmi/bmi_input.dart';
import 'package:meta/meta.dart';

class InputBmiDataModel {
  final List<InputBmiModel> inputs;
  final bool hasMore;

  InputBmiDataModel({required this.inputs, required this.hasMore});
}
