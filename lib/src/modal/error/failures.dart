import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:medical/res/R.dart';

class Failure extends Equatable {
  final String? message;

  Failure({this.message});

  @override
  List<Object?> get props => throw Failure(message: message);
}
