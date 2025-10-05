import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences.getInstance().then((value) => preferences = value);
  }

  final WeightRepository _weightRepository;
  late SharedPreferences preferences;

  // data
  List<WeightInstructionModel> _weightInstructions = [];
  List<WeightInstructionModel> get weightInstructions => _weightInstructions;

  List<BmiWeightLesson> _lessons = [];
  List<BmiWeightLesson> get lessons => _lessons;

  // BmiGetWeightListResponse? _historicalWeightResponse;
  List<BmiGetWeightRecord> _historicalWeightList = [];

  late DateTime _currentTime;
  DateTime? _selectedTimeOnChart;
  BmiDateFilterType _periodType = BmiDateFilterType.aMonth;
  BmiDateFilterType get periodType => _periodType;

  BmiWeightStatistical? _weightStatistical;
  BmiStatistical? _bmiStatistical;
  BmiWaistStatistical? _bmiWaistStatistical;

  String _aiAnalysicTrend = "";
  String _aiAnalysicWeightRecord = "";

  bool _hasInputedWaist = false;
  bool get hasInputedWaist => _hasInputedWaist;

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
  String get aiAnalysicWeightRecord => _aiAnalysicWeightRecord;

  double? get height => _bmiStatistical?.height;
  double get weightGoal => AppSettings.weightGoal;

  bool hasNewData = false;

  bool get hasStatisticalData =>
      preferences.getBool(Const.hasWeightRecord) ?? false;

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

    final response = await _weightRepository.analyzeWeightIndex(event.recordId);

    response.when(
        success: (data) {
          _aiAnalysicWeightRecord = data;
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
        success: (data) async {
          _bmiWaistStatistical = data;
          emit(BmiGetWaistStatisticalState(Resource.success(data)));

          if ((data.trendItems?.isNotEmpty ?? false) &&
              [
                BmiDateFilterType.aMonth,
                BmiDateFilterType.threeMonths,
              ].contains(_periodType)) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setBool(Const.hasInputedWaist, true);
          }
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
    //     await rootBundle.loadString('assets/dummy/weight_lessons.json');

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
    _periodType = BmiDateFilterType.aMonth;

    add(BmiInstructionFetchingEvent());
    add(BmiGetWeightLessonsEvent());

    add(BmiGetWeightStatisticalEvent());
    add(BmiGetWaistStatisticalEvent());

    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      add(BmiGetAIAnalysicEvent());
      _hasInputedWaist = preferences.getBool(Const.hasInputedWaist) ?? false;
    });
  }

  Future<bool> checkRecordExisted() async {
    _currentTime = DateTime.now();
    final response = await _weightRepository.getWeightStatisticalData(
      currentTime: _currentTime.millisecondsSinceEpoch,
      periodFilterType: BmiDateFilterType.threeMonths.requestValue,
      page: 1,
    );
    add(BmiGetBmiStatisticalEvent(_currentTime));

    return response.when(
      success: (data) => data.trendItems?.isNotEmpty ?? false,
      failure: (error) => false,
    );
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

  void getAIAnalysicWeightRecord(String recordId) {
    add(BmiGetAIIndexAnalysicEvent(recordId));
  }

  void selectPointChart(DateTime time) {
    _selectedTimeOnChart = time;
    add(BmiGetBmiStatisticalEvent(time));
  }

  Map<DateTime, List<BmiGetWeightRecord>> getGroupedWeightRecords() {
    Map<DateTime, List<BmiGetWeightRecord>> result = {};

    for (var item in _historicalWeightList) {
      final time = DateTime.fromMillisecondsSinceEpoch(item.date! * 1000);
      final DateTime date = DateTime(time.year, time.month, time.day);

      result.update(
        date,
        (value) => [item],
        ifAbsent: () => [item],
      );
    }

    return result;
  }
}
