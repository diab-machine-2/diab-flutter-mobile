import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MyBookingState extends Equatable {
  MyBookingState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialMyBookingState extends MyBookingState {}

class MyBookingLoading extends MyBookingState {
  @override
  String toString() => 'MyBookingLoading';
}

class MyBookingSuccess extends MyBookingState {
  @override
  String toString() {
    return 'MyBookingSuccess';
  }
}

class MyBookingFailure extends MyBookingState {
  final String error;

  MyBookingFailure(this.error);

  @override
  String toString() => 'MyBookingFailure { error: $error }';
}

class SelectedDateSuccess extends MyBookingState {
  @override
  String toString() {
    return 'SelectedDateSuccess';
  }
}
