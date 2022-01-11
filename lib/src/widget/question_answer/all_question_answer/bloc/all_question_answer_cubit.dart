import 'package:flutter_bloc/flutter_bloc.dart';
import '../all_question_answer.dart';

class AllQuestionAnswerCubit extends Cubit<AllQuestionAnswerState> {
  List<String> topic = ['Tất cả', 'Vận động', 'Dinh dưỡng', 'HbA1C', 'Đường huyết', 'Từ khóa', 'Chế độ tập luyện'];
  int currentTopic = 0;

  AllQuestionAnswerCubit() : super(AllQuestionAnswerInitial()) {
    // TODO
  }

  onSelectWeek(int index) {
    currentTopic = index;
    emit(AllQuestionAnswerLoading());
    emit(AllQuestionAnswerSuccess());
  }
}
