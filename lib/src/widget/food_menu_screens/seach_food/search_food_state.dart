import 'package:equatable/equatable.dart';

abstract class SearchFoodState extends Equatable {
  const SearchFoodState() : super();

  @override
  List<Object> get props => [];
}

class SearchFoodInitial extends SearchFoodState {
  const SearchFoodInitial();
  @override
  String toString() {
    return 'SearchFoodInitial{}';
  }
}

class SearchFoodFailure extends SearchFoodState {
  final String? error;

  const SearchFoodFailure(this.error);

  @override
  String toString() {
    return 'SearchFoodFailure {error: $error}';
  }
}

class SearchFoodSuccess extends SearchFoodState {
  const SearchFoodSuccess();
  @override
  String toString() {
    return 'SearchFoodSuccess{}';
  }
}

class SearchFoodLoading extends SearchFoodState {
  const SearchFoodLoading();
  @override
  String toString() {
    return 'SearchFoodLoading{}';
  }
}