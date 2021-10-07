import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class KcalParameterState extends Equatable {
  KcalParameterState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialKcalParameterState extends KcalParameterState {}

class KcalParameterLoading extends KcalParameterState {
  @override
  String toString() => 'KcalParameterLoading';
}

class KcalParameterSuccess extends KcalParameterState {
  @override
  String toString() {
    return 'KcalParameterSuccess';
  }
}

class KcalParameterFailure extends KcalParameterState {
  final String error;

  KcalParameterFailure(this.error);

  @override
  String toString() => 'KcalParameterFailure { error: $error }';
}


