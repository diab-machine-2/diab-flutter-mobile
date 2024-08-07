import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';

@immutable
abstract class CalendarBookingState extends Equatable {
  const CalendarBookingState();

  @override
  List<Object> get props => [];
}

class InitialCalendarBookingState extends CalendarBookingState {
  @override
  String toString() {
    return 'InitialCalendarBookingState';
  }
}

class CalendarBookingLoading extends CalendarBookingState {
  @override
  String toString() => 'CalendarBookingLoading';
}

class CalendarBookingSuccess extends CalendarBookingState {
  @override
  String toString() {
    return 'CalendarBookingSuccess';
  }
}

class DeleteCalendarSuccess extends CalendarBookingState {
  @override
  String toString() {
    return 'DeleteCalendarSuccess';
  }
}

class CreateCalendarSuccess extends CalendarBookingState {
  final CreateCalendarResponse response;

  CreateCalendarSuccess(this.response);

  @override
  String toString() => 'CreateCalendarSuccess';
}

class CalendarBookingFailure extends CalendarBookingState {
  final String error;

  const CalendarBookingFailure(this.error);

  @override
  String toString() => 'CalendarBookingFailure { error: $error }';
}
