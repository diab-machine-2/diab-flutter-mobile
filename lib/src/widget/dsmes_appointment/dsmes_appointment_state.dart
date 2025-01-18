import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';

@immutable
abstract class DsmesAppointmentState extends Equatable {
  const DsmesAppointmentState();

  @override
  List<Object> get props => [];
}

class InitialDsmesAppointmentState extends DsmesAppointmentState {
  @override
  String toString() {
    return 'InitialDsmesAppointmentState';
  }
}

class DsmesAppointmentLoading extends DsmesAppointmentState {
  @override
  String toString() => 'DsmesAppointmentLoading';
}

class DsmesAppointmentCloseLoading extends DsmesAppointmentState {
  @override
  String toString() => 'DsmesAppointmentCloseLoading';
}

class DsmesAppointmentLoaded extends DsmesAppointmentState {
  DsmesAppointmentLoaded();

  @override
  String toString() => 'DsmesAppointmentLoaded';
}

class DeleteDsmesAppointmentSuccess extends DsmesAppointmentState {
  @override
  String toString() {
    return 'DeleteDsmesAppointmentSuccess';
  }
}

class CreateDsmesAppointmentSuccess extends DsmesAppointmentState {
  final CreateCalendarResponse response;

  CreateDsmesAppointmentSuccess(this.response);

  @override
  String toString() => 'CreateDsmesAppointmentSuccess';
}

class DsmesAppointmentFailure extends DsmesAppointmentState {
  final String error;

  const DsmesAppointmentFailure(this.error);

  @override
  String toString() => 'DsmesAppointmentFailure { error: $error }';
}
