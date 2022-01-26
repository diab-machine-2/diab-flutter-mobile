import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import '../question_detail.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState> {
  final QuestionModel questionModel;

  QuestionDetailCubit(this.questionModel) : super(QuestionDetailInitial()) {
    // TODO
  }

  String getStatus(int status) {
    switch (status) {
      case 0:
        return R.string.closed.tr();
      case 1:
        return R.string.waiting.tr();
      case 2:
        return R.string.replied.tr();
      default:
        return '';
    }
  }

  Color getColorStatus(int status) {
    switch (status) {
      case 0:
        return R.color.red;
      case 1:
        return R.color.yellow;
      case 2:
        return R.color.greenGradientBottom;
      default:
        return R.color.transparent;
    }
  }
}
