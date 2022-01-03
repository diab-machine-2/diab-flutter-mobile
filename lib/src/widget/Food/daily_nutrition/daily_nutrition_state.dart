import 'package:equatable/equatable.dart';

abstract class DailyNutritionState extends Equatable {
  const DailyNutritionState() : super();

  @override
  List<Object> get props => [];
}

class DailyNutritionInitial extends DailyNutritionState {
  const DailyNutritionInitial();
  @override
  String toString() {
    return 'DailyNutritionInitial{}';
  }
}

class DailyNutritionFailure extends DailyNutritionState {
  final String? error;

  const DailyNutritionFailure(this.error);

  @override
  String toString() {
    return 'DailyNutritionFailure {error: $error}';
  }
}

class DailyNutritionSuccess extends DailyNutritionState {
  const DailyNutritionSuccess();
  @override
  String toString() {
    return 'DailyNutritionSuccess{}';
  }
}

class DailyNutritionLoading extends DailyNutritionState {
  const DailyNutritionLoading();
  @override
  String toString() {
    return 'DailyNutritionLoading{}';
  }
}

class DailyNutritionSubmitSuccess extends DailyNutritionState {
  const DailyNutritionSubmitSuccess();
  @override
  String toString() {
    return 'DailyNutritionSubmitSuccess{}';
  }
}

class DailyNutritionFillData extends DailyNutritionState {
  const DailyNutritionFillData();
  @override
  String toString() {
    return 'DailyNutritionFillData{}';
  }
}
