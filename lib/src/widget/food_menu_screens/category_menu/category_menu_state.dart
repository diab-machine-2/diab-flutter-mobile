import 'package:equatable/equatable.dart';

abstract class CategoryMenuState extends Equatable {
  const CategoryMenuState() : super();

  @override
  List<Object> get props => [];
}

class CategoryMenuInitial extends CategoryMenuState {
  const CategoryMenuInitial();
  @override
  String toString() {
    return 'CategoryMenuInitial{}';
  }
}

class CategoryMenuFailure extends CategoryMenuState {
  final String? error;

  const CategoryMenuFailure(this.error);

  @override
  String toString() {
    return 'CategoryMenuFailure {error: $error}';
  }
}

class CategoryMenuSuccess extends CategoryMenuState {
  const CategoryMenuSuccess();
  @override
  String toString() {
    return 'CategoryMenuSuccess{}';
  }
}

class CategoryMenuLoading extends CategoryMenuState {
  const CategoryMenuLoading();
  @override
  String toString() {
    return 'CategoryMenuLoading{}';
  }
}