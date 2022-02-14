import 'package:medical/src/modal/emotion/input_emotion_model.dart';
import 'package:meta/meta.dart';
@immutable
class InputEmotionDataModel {
  final List<InputEmotionModel> inputs;
  final bool? hasMore;

  const InputEmotionDataModel({required this.inputs, required this.hasMore});
}
