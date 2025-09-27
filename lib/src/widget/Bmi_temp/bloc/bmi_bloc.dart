import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/weight_repository.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
import 'package:medical/src/widget/Bmi/models/weight_instruction_model.dart';

class BmiBloc extends Bloc<BmiEvent, BmiState> {
  BmiBloc(WeightRepository repository)
      : _weightRepository = repository,
        super(BmiGetInstructionState(Resource.loading())) {
    on<BmiInstructionFetchingEvent>(_onGetInstruction);
    on<BmiDataChangeEvent>(_onDataChanged);
    on<BmiGetWeightStatisticalEvent>(_onFetchWeightStatistical);
    on<BmiGetWaistStatisticalEvent>(_onFetchWaistStatistical);
    on<BmiGetBmiStatisticalEvent>(_onFetchBmiStatistical);
    on<BmiGetWeightLessonsEvent>(_onFetchWeightLessons);
    on<BmiGetWeightRecordsEvent>(_onFetchWeightRecords);
    on<BmiGetAIAnalysicEvent>(_onGetAIAnalysis);
    on<BmiGetAIIndexAnalysicEvent>(_onGetAIIndexAnalysis);
  }

  final WeightRepository _weightRepository;

  // data
  List<WeightInstructionModel> _weightInstructions = [];
  List<WeightInstructionModel> get weightInstructions => _weightInstructions;

  List<BmiWeightLesson> _lessons = [];
  List<BmiWeightLesson> get lessons => _lessons;

  BmiGetWeightListResponse? _historicalWeightResponse;
  List<BmiGetWeightRecord> _historicalWeightList = [];

  late DateTime _currentTime;
  DateTime? _selectedTimeOnChart;
  BmiDateFilterType _periodType = BmiDateFilterType.aWeek;
  BmiDateFilterType get periodType => _periodType;

  BmiWeightStatistical? _weightStatistical;
  BmiStatistical? _bmiStatistical;
  BmiWaistStatistical? _bmiWaistStatistical;

  String _aiAnalysicTrend = "";
  String _aiAnalysicIndex = "";

  // getter & setter
  double? get avgBmi => _bmiStatistical?.value;
  double? get highestBmi => null;
  double? get lowestBmi => null;

  // double? get highestWeight => _weightStatistical?.highest;
  // double? get lowestWeight => _weightStatistical?.lowest;

  BmiWeightStatistical? get weightStatistical => _weightStatistical;
  BmiStatistical? get bmiStatistical => _bmiStatistical;
  BmiWaistStatistical? get bmiWaistStatistical => _bmiWaistStatistical;

  List<BmiGetWeightRecord> get historicalWeightList => _historicalWeightList;

  String get aiAnalysicTrend => _aiAnalysicTrend;
  String get aiAnalysicIndex => _aiAnalysicIndex;

  double? get height => _bmiStatistical?.height;
  double get weightGoal => AppSettings.weightGoal;

  bool hasNewData = false;

  bool get hasStatisticalData =>
      _weightStatistical != null ||
      _bmiStatistical != null ||
      _bmiWaistStatistical != null;

  DateTime? get selectedTimeOnChart => _selectedTimeOnChart;

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

  void _onGetAIAnalysis(
    BmiGetAIAnalysicEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetAIAnalysicState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/weight_statistical.json');

    // final result = BmiWeightStatistical.fromJson(jsonDecode(raw)["data"]);
    // emit(BmiGetWeightStatisticalState(Resource.success(result)));
    // _weightStatistical = result;
    // return;

    final response = await _weightRepository.analyzeWeightTrend(
        currentTime: _currentTime.millisecondsSinceEpoch,
        periodFilterType: _periodType.requestValue,
        page: 1);

    response.when(
        success: (data) {
          _aiAnalysicTrend = data;
          emit(BmiGetAIAnalysicState(Resource.success(data)));
        },
        failure: (error) => emit(BmiGetAIAnalysicState(Resource.error(error))));
  }

  void _onGetAIIndexAnalysis(
    BmiGetAIIndexAnalysicEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetAIIndexAnalysicState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/weight_statistical.json');

    // final result = BmiWeightStatistical.fromJson(jsonDecode(raw)["data"]);
    // emit(BmiGetWeightStatisticalState(Resource.success(result)));
    // _weightStatistical = result;
    // return;

    final response = await _weightRepository.analyzeWeightIndex("");

    response.when(
        success: (data) {
          _aiAnalysicIndex = data;
          emit(BmiGetAIIndexAnalysicState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetAIIndexAnalysicState(Resource.error(error))));
  }

  void _onFetchWeightStatistical(
    BmiGetWeightStatisticalEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetWeightStatisticalState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/weight_statistical.json');

    // final result = BmiWeightStatistical.fromJson(jsonDecode(raw)["data"]);
    // emit(BmiGetWeightStatisticalState(Resource.success(result)));
    // _weightStatistical = result;
    // return;

    final response = await _weightRepository.getWeightStatisticalData(
        currentTime: _currentTime.millisecondsSinceEpoch,
        periodFilterType: _periodType.requestValue,
        page: 1);

    response.when(
        success: (data) {
          _weightStatistical = data;
          if (data.trendItems?.isNotEmpty ?? false) {
            _selectedTimeOnChart = DateTime.fromMillisecondsSinceEpoch(
                data.trendItems!.first.date! * 1000);
            add(BmiGetBmiStatisticalEvent(_selectedTimeOnChart!));
          }
          emit(BmiGetWeightStatisticalState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetWeightStatisticalState(Resource.error(error))));
  }

  void _onFetchWaistStatistical(
    BmiGetWaistStatisticalEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetWaistStatisticalState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/waist_statistical.json');

    // final result = BmiWaistStatistical.fromJson(jsonDecode(raw)["data"]);
    // emit(BmiGetWaistStatisticalState(Resource.success(result)));
    // _bmiWaistStatistical = result;
    // return;

    final response = await _weightRepository.getWaistStatisticalData(
        currentTime: _currentTime.millisecondsSinceEpoch,
        periodFilterType: _periodType.requestValue,
        page: 1);

    response.when(
        success: (data) {
          _bmiWaistStatistical = data;
          emit(BmiGetWaistStatisticalState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetWaistStatisticalState(Resource.error(error))));
  }

  void _onFetchBmiStatistical(
    BmiGetBmiStatisticalEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetBmiStatisticalState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/bmi_statistical.json');

    // final result = BmiStatistical.fromJson(jsonDecode(raw)["data"]);
    // emit(BmiGetBmiStatisticalState(Resource.success(result)));
    // _bmiStatistical = result;
    // return;

    final response = await _weightRepository.getBmiStatisticalData(
        currentTime: event.time.millisecondsSinceEpoch,
        periodFilterType: _periodType.requestValue,
        page: 1);

    response.when(
        success: (data) {
          _bmiStatistical = data;
          emit(BmiGetBmiStatisticalState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetBmiStatisticalState(Resource.error(error))));
  }

  void _onFetchWeightLessons(
    BmiGetWeightLessonsEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetWeightLessonsState(Resource.loading()));
    // final String raw =
    //     await rootBundle.loadString('assets/dummy/bmi_weight_lesson.json');

    // final result = (jsonDecode(raw)["data"] as List)
    //     .map((e) => BmiWeightLesson.fromJson(e))
    //     .toList();
    // emit(BmiGetWeightLessonsState(Resource.success(result)));
    // _lessons = result;
    // return;

    final response = await _weightRepository.getWeightLessons();
    response.when(
        success: (data) =>
            emit(BmiGetWeightLessonsState(Resource.success(data))),
        failure: (error) =>
            emit(BmiGetWeightLessonsState(Resource.error(error))));
  }

  void _onFetchWeightRecords(
    BmiGetWeightRecordsEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetWeightIndexListState(Resource.loading()));

    // final String raw =
    //     await rootBundle.loadString('assets/dummy/weight_list.json');

    // final result = (jsonDecode(raw)["data"] as List)
    //     .map((e) => BmiGetWeightRecord.fromJson(e))
    //     .toList();
    // // emit(BmiGetWeightIndexListState(Resource.success(result)));
    // _historicalWeightList = result;
    // return;

    final response = await _weightRepository.getWeightIndexList(
      currentTime: _currentTime.millisecondsSinceEpoch,
      periodFilterType: _periodType.requestValue,
    );
    response.when(
        success: (data) {
          _historicalWeightList = data.data ?? [];
          emit(BmiGetWeightIndexListState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetWeightIndexListState(Resource.error(error))));
  }

  // public func
  void init() {
    _currentTime = DateTime.now();
    add(BmiInstructionFetchingEvent());
    add(BmiGetWeightLessonsEvent());

    // add(BmiGetBmiStatisticalEvent());
    add(BmiGetWeightStatisticalEvent());
    add(BmiGetWaistStatisticalEvent());

    Future.delayed(Duration(milliseconds: 1000))
        .then((value) => add(BmiGetAIAnalysicEvent()));
  }

  void changePeriodTime(BmiDateFilterType period,
      {required bool isStatisticalView}) {
    if (period == _periodType) return;
    _periodType = period;
    if (isStatisticalView) {
      // add(BmiGetBmiStatisticalEvent());
      add(BmiGetWeightStatisticalEvent());
      add(BmiGetWaistStatisticalEvent());
      add(BmiGetAIAnalysicEvent());
    } else {
      //load detail
      add(BmiGetWeightRecordsEvent());
    }
  }

  void fetchHistoricalWeight() {
    add(BmiGetWeightRecordsEvent());
  }

  void analyzeBmiRecord() {
    add(BmiGetAIIndexAnalysicEvent());
  }

  void selectPointChart(DateTime time) {
    _selectedTimeOnChart = time;
    add(BmiGetBmiStatisticalEvent(time));
  }
}
