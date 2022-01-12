import 'package:flutter_bloc/flutter_bloc.dart';
import '../make_question.dart';

class MakeQuestionCubit extends Cubit<MakeQuestionState> {
  List<String> topicList = ["Chủ đề 1", "Chủ đề 2", "Chủ đề 3", "Chủ đề 4", "Chủ đề 5"];
  String? currentTopic;

  MakeQuestionCubit() : super(MakeQuestionInitial()) {
    // TODO
  }

  setCurrentTopic(String topic) {
    currentTopic = topic;
    emit(MakeQuestionLoading());
    emit(MakeQuestionSuccess());
  }
}
