import 'package:equatable/equatable.dart';

abstract class IntroSampleMenuState extends Equatable {
  IntroSampleMenuState([List props = const []]) : super();

  @override
  // TODO: implement props
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

  IntroSampleMenuFailure(this.error);

  @override
  String toString() => 'IntroSampleMenuFailure { error: $error }';
}