import 'package:medical/modal/HbA1C/HbA1C_Input.dart';
import 'package:meta/meta.dart';

class InputHbA1CDataModel {
  final List<InputHbA1CModel> inputs;
  final bool hasMore;

  InputHbA1CDataModel({@required this.inputs, @required this.hasMore});
}
