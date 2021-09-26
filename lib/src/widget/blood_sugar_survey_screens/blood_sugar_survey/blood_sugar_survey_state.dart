import 'package:equatable/equatable.dart';
import 'package:medical/src/model/response/blood_sugar_template_category_response.dart';

abstract class BloodSugarSurveyState extends Equatable {
  const BloodSugarSurveyState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarSurveyInitial extends BloodSugarSurveyState {
  const BloodSugarSurveyInitial();
  @override
  String toString() {
    return 'BloodSugarSurveyInitial{}';
  }
}

class BloodSugarSurveyFailure extends BloodSugarSurveyState {
  final String? error;

  const BloodSugarSurveyFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarSurveyFailure {error: $error}';
  }
}

class BloodSugarSurveySuccess extends BloodSugarSurveyState {
  const BloodSugarSurveySuccess();
  @override
  String toString() {
    return 'BloodSugarSurveySuccess{}';
  }
}

class BloodSugarSurveyLoading extends BloodSugarSurveyState {
  const BloodSugarSurveyLoading();
  @override
  String toString() {
    return 'BloodSugarSurveyLoading{}';
  }
}

class BloodSugarSurveyNavigate extends BloodSugarSurveyState {
  const BloodSugarSurveyNavigate(this.listBloodSugarTemplateCategory);
  final List<BloodSugarTemplateCategory> listBloodSugarTemplateCategory;

  @override
  String toString() {
    return 'BloodSugarSurveyNavigate{}';
  }
}