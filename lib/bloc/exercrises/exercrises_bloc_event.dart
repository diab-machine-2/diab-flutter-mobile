part of 'exercrises_bloc.dart';

@immutable
abstract class ExercrisesEvent {}

class FetchCategory extends ExercrisesEvent {
  final int page;
  final List<ExercrisesCategoryModel> selectedModel;
  FetchCategory({this.page, this.selectedModel});
}

class AddCategory extends ExercrisesEvent {
  final ExercrisesCategoryModel selectedModel;
  AddCategory({
    this.selectedModel,
  });
}

class SearchCategory extends ExercrisesEvent {
  final String key;
  SearchCategory({
    this.key,
  });
}

class FetchTimeTrend extends ExercrisesEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchTimeTrend({this.currentDateTime, this.periodFilterType});
}

class FetchInputExercrises extends ExercrisesEvent {
  final String currentDateTime;
  final String periodFilterType;
  final int page;

  FetchInputExercrises(
      {this.currentDateTime, this.periodFilterType, this.page});
}

class FetchDataDaily extends ExercrisesEvent {
  final String currentDateTime;

  FetchDataDaily({this.currentDateTime});
}

class FetchCaloTrend extends ExercrisesEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchCaloTrend({this.currentDateTime, this.periodFilterType});
}

class FetchRank extends ExercrisesEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchRank({this.currentDateTime, this.periodFilterType});
}
