import 'package:equatable/equatable.dart';
import 'package:medical/src/modal/error/failures.dart';

abstract class CubitBaseState extends Equatable {}

class BaseStateWithoutProps extends CubitBaseState {
  @override
  List<Object?> get props => [];
}

class InitialState extends BaseStateWithoutProps {}

class LoadingState extends BaseStateWithoutProps {}

abstract class LoadingCompleteState extends CubitBaseState {}

class LoadingCompleteStateWithoutProps extends LoadingCompleteState {
  @override
  List<Object?> get props => [];
}

class ErrorState extends LoadingCompleteState {
  final Failure failure;
  ErrorState(this.failure);

  @override
  List<Object?> get props => [failure];
}

class DataLoadedState<T> extends LoadingCompleteState {
  final T? data;

  DataLoadedState({this.data});

  @override
  List<Object?> get props => [data];
}
