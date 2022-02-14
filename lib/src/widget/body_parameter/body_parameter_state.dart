import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BodyParameterState extends Equatable {
  const BodyParameterState();

  @override
  List<Object> get props => [];
}

class InitialBodyParameterState extends BodyParameterState {}

class BodyParameterLoading extends BodyParameterState {
  @override
  String toString() => 'BodyParameterLoading';
}

class BodyParameterSuccess extends BodyParameterState {
  @override
  String toString() {
    return 'BodyParameterSuccess';
  }
}

class GetTDEESuccess extends BodyParameterState {
  @override
  String toString() {
    return 'GetTDEESuccess';
  }
}

class BodyParameterFailure extends BodyParameterState {
  final String error;

  const BodyParameterFailure(this.error);

  @override
  String toString() => 'BodyParameterFailure { error: $error }';
}
