import 'package:medical/modal/emotion/input_emotion_model.dart';
import 'package:meta/meta.dart';

class InputEmotionDataModel {
  final List<InputEmotionModel> inputs;
  final bool hasMore;

  InputEmotionDataModel({@required this.inputs, @required this.hasMore});
}
