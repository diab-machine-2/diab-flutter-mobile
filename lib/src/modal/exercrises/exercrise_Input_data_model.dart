import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:meta/meta.dart';

class InputExercrisesDataModel {
  final List<InputDataExercriseModel> inputs;
  final bool hasMore;

  InputExercrisesDataModel({@required this.inputs, @required this.hasMore});
}
