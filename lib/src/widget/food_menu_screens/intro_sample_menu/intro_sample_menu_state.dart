import 'package:equatable/equatable.dart';

abstract class IntroSampleMenuState extends Equatable {
  const IntroSampleMenuState();

  @override
  List<Object> get props => [];
}

class IntroSampleMenuInitial extends IntroSampleMenuState {
  @override
  String toString() => 'IntroSampleMenuInitial';
}

class IntroSampleMenuLoading extends IntroSampleMenuState {
  @override
  String toString() => 'IntroSampleMenuLoading';
}

class IntroSampleMenuFailure extends IntroSampleMenuState {
  final String error;

  const IntroSampleMenuFailure(this.error);

  @override
  String toString() => 'IntroSampleMenuFailure { error: $error }';
}