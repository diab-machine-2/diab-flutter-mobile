import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BookingCoachState extends Equatable {
  const BookingCoachState();

  @override
  List<Object> get props => [];
}

class InitialBookingCoachState extends BookingCoachState {}

class BookingCoachLoading extends BookingCoachState {
  @override
  String toString() => 'BookingCoachLoading';
}

class BookingCoachSuccess extends BookingCoachState {
  @override
  String toString() {
    return 'BookingCoachSuccess';
  }
}

class BookingCoachFailure extends BookingCoachState {
  final String error;

  const BookingCoachFailure(this.error);

  @override
  String toString() => 'BookingCoachFailure { error: $error }';
}

class SelectedDateSuccess extends BookingCoachState {
  @override
  String toString() {
    return 'SelectedDateSuccess';
  }
}
