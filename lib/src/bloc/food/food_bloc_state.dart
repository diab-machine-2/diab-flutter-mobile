part of 'food_bloc.dart';

@immutable
abstract class FoodState {}

class FoodInitial extends FoodState {}

class FoodError extends FoodState {
  final String? message;

  FoodError({
    required this.message,
  });
}

class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final FoodDataModel model;
  final FoodDataModel? searchModel;
  FoodLoaded({required this.model, this.searchModel});
}

class FoodSearchLoaded extends FoodState {
  final FoodCategoryDataModel? searchModel;
  FoodSearchLoaded({this.searchModel});
}

class FoodCategoryLoaded extends FoodState {
  final List<FoodCategoryModel> model;
  FoodCategoryLoaded({required this.model});
}

class FoodInputLoaded extends FoodState {
  final List<MealDayItemModel> inputs;
  final bool? hasMore;
  FoodInputLoaded({required this.inputs, required this.hasMore});
}

class FoodStatisticCaloLoaded extends FoodState {
  final FoodCaloModel model;
  FoodStatisticCaloLoaded({required this.model});
}

class FoodStatisticCarbLoaded extends FoodState {
  final FoodCaloModel? model;
  FoodStatisticCarbLoaded({this.model});
}

class FoodStatisticDetailLoaded extends FoodState {
  final FoodDietModel? model;
  FoodStatisticDetailLoaded({this.model});
}

class FoodStatisticTrendLoaded extends FoodState {
  final FoodTrendModel? model;

  FoodStatisticTrendLoaded({this.model});
}

class FoodStatisticDistributeLoaded extends FoodState {
  final FoodDistributeModel? model;

  FoodStatisticDistributeLoaded({this.model});
}
