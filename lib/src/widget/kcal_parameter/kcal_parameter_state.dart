import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class KcalParameterState extends Equatable {
  const KcalParameterState();

  @override
  List<Object> get props => [];
}

class InitialKcalParameterState extends KcalParameterState {}

class KcalParameterLoading extends KcalParameterState {
  const KcalParameterLoading();
  @override
  String toString() => 'KcalParameterLoading';
}

class KcalParameterSuccess extends KcalParameterState {
  const KcalParameterSuccess();
  @override
  String toString() {
    return 'KcalParameterSuccess';
  }
}

class KcalParameterFailure extends KcalParameterState {
  const KcalParameterFailure(this.error);

  final String error;

  @override
  String toString() => 'KcalParameterFailure { error: $error }';
}

class KcalParameterKcalChanged extends KcalParameterState {
  const KcalParameterKcalChanged(this.kcal);

  final int? kcal;

  @override
  String toString() => 'KcalParameterKcalChanged { kcal: $kcal }';
}


