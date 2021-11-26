import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:meta/meta.dart';
@immutable
class InputHbA1CDataModel {
  final List<InputHbA1CModel> inputs;
  final bool? hasMore;

  const InputHbA1CDataModel({required this.inputs, required this.hasMore});
}
