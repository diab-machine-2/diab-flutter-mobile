import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/bmi/models/weight_instruction_model.dart';

class BmiBloc extends Bloc<BmiEvent, BmiState> {
  BmiBloc() : super(BmiGetInstructionState(Resource.loading())) {
    on<BmiInstructionFetchingEvent>(_onGetInstruction);
    on<BmiDataChangeEvent>(_onDataChanged);
    on<BmiGetWeightStatisticalEvent>(_onFetchWeightStatistical);
    on<BmiGetWaistStatisticalEvent>(_onFetchWaistStatistical);
    on<BmiGetBmiStatisticalEvent>(_onFetchBmiStatistical);
  }

  // data
  List<WeightInstructionModel> _weightInstructions = [];
  List<WeightInstructionModel> get weightInstructions => _weightInstructions;

  // getter & setter
  double get avgBmi => 25.4;
  double get highestBmi => 30;
  double get lowestBmi => 18;

  void _onGetInstruction(
    BmiInstructionFetchingEvent event,
    Emitter<BmiState> emit,
  ) async {
    try {
      emit(BmiGetInstructionState(Resource.loading()));
      final String raw =
          await rootBundle.loadString('assets/dummy/bmi_instruction.json');

      final result = (jsonDecode(raw)["data"] as List)
          .map((e) => WeightInstructionModel.fromJson(e))
          .toList();

      _weightInstructions = result;
      emit(BmiGetInstructionState(Resource.success(result)));
    } catch (e) {
      emit(BmiGetInstructionState(Resource.error(e)));
    }
  }

  void _onDataChanged(
    BmiDataChangeEvent event,
    Emitter<BmiState> emit,
  ) {
    emit(BmiDataChangedState(event.event, event.data));
  }

  void _onFetchWeightStatistical(
    BmiGetWeightStatisticalEvent event,
    Emitter<BmiState> emit,
  ) {
    // emit(BmiDataChangedState(event.event, event.data));
  }

  void _onFetchWaistStatistical(
    BmiGetWaistStatisticalEvent event,
    Emitter<BmiState> emit,
  ) {
    // emit(BmiDataChangedState(event.event, event.data));
  }

  void _onFetchBmiStatistical(
    BmiGetBmiStatisticalEvent event,
    Emitter<BmiState> emit,
  ) {
    // emit(BmiGetBmiStatisticalState(event.event, event.data));
  }

  // public func
  void init() {
    add(BmiInstructionFetchingEvent());
  }
}
