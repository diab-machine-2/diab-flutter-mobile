import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/weight_repository.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/model/response/get_weight_threshold_response.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/utils/app_storages.dart';
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
    on<BmiGetWeightThresholdEvent>(_onThresholdFetched);
    on<BmiDataChangeEvent>(_onDataChanged);
    on<BmiGetWeightStatisticalEvent>(_onFetchWeightStatistical);
    on<BmiGetWaistStatisticalEvent>(_onFetchWaistStatistical);
    on<BmiGetBmiStatisticalEvent>(_onFetchBmiStatistical);
    on<BmiCheckStatisticalDataExistedEvent>(
        _onCheckWeightStatisticalDataExisted);
    on<BmiGetWeightLessonsEvent>(_onFetchWeightLessons);
    on<BmiGetWeightRecordsEvent>(_onFetchWeightRecords);
    on<BmiGetAIAnalysicEvent>(_onGetAIAnalysis);
    on<BmiGetAIIndexAnalysicEvent>(_onGetAIIndexAnalysis);
    on<BmiUpdateWeightGoalEvent>(_onUpdateWeightGoal);

    SharedPreferences.getInstance().then((value) => preferences = value);
    AppStorages.getHealthAppPermission().then(
      (value) => _hasHealthAppPermission = value ?? false,
    );
  }

  final WeightRepository _weightRepository;
  late SharedPreferences preferences;

  // data
  List<WeightThreshold> _weightThreshold = [];
  List<WeightThreshold> get weightThreshold => _weightThreshold;

  List<WeightInstructionModel> _weightInstructions = [];
  List<WeightInstructionModel> get weightInstructions => _weightInstructions;

  List<BmiWeightLesson> _lessons = [];
  List<BmiWeightLesson> get lessons => _lessons;

  List<BmiWeightLesson> _lessonsSupport = [];
  List<BmiWeightLesson> get lessonsSupport => _lessonsSupport;

  // BmiGetWeightListResponse? _historicalWeightResponse;
  List<BmiGetWeightRecord> _historicalWeightList = [];

  late DateTime _currentTime;

  BmiGetWeightRecord? _selectedPointChart;
  int? _selectedIndexPointChart;

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
  double get highestWeight => _weightStatistical?.highest ?? 0;
  double get lowestWeight => _weightStatistical?.lowest ?? 0;

  double getHighestOfChart(double margin) {
    if (weightGoal == null) return highestWeight + margin;
    if (highestWeight + margin < weightGoal!) {
      return weightGoal! + margin;
    } else {
      return highestWeight + margin;
    }
  }

  double getLowestOfChart(double margin) {
    if (weightGoal == null) return lowestWeight - margin;
    if (lowestWeight - margin > weightGoal!) {
      return weightGoal! - margin;
    } else {
      return lowestWeight - margin;
    }
  }

  double? get avgBmi => _bmiStatistical?.value;
  double? get highestBmi {
    if (height != null && height! > 0) {
      double result = highestWeight / pow(height! / 100, 2);
      return double.parse(result.toStringAsFixed(1));
    }
    return null;
  }

  double? get lowestBmi {
    if (height != null && height! > 0) {
      double result = lowestWeight / pow(height! / 100, 2);
      return double.parse(result.toStringAsFixed(1));
    }
    return null;
  }

  BmiWeightStatistical? get weightStatistical => _weightStatistical;
  BmiStatistical? get bmiStatistical => _bmiStatistical;
  BmiWaistStatistical? get bmiWaistStatistical => _bmiWaistStatistical;

  List<BmiGetWeightRecord> get historicalWeightList => _historicalWeightList;

  String get aiAnalysicTrend => _aiAnalysicTrend;
  String get aiAnalysicWeightRecord => _aiAnalysicWeightRecord;

  double? get height => AppSettings.userInfo?.height;
  set height(double? value) {
    add(BmiDataChangeEvent(BmiDataChangeEvent.heightChanged, value));
  }

  double? get weightGoal {
    if (AppSettings.userInfo?.goalWeight == null ||
        AppSettings.userInfo?.goalWeight == 0) {
      return null;
    }
    return AppSettings.userInfo!.goalWeight!;
  }

  set weightGoal(double? value) {
    AppSettings.userInfo = AppSettings.userInfo?.copyWith(goalWeight: value);
    add(BmiDataChangeEvent(BmiDataChangeEvent.weightGoalChanged, value));
  }

  bool _hasNewData = false;
  bool get hasNewData => _hasNewData;
  set hasNewData(bool value) {
    _hasNewData = value;
    add(BmiDataChangeEvent(BmiDataChangeEvent.hasDataChanged, value));
  }

  late bool _hasHealthAppPermission;
  bool get hasHealthAppPermission => _hasHealthAppPermission;

  bool _hasStatisticalData = false;
  bool get hasStatisticalData =>
      preferences.getBool(Const.hasWeightRecord) ?? false;

  BmiGetWeightRecord? get selectedPointChart => _selectedPointChart;
  int? get selectedIndexPointChart => _selectedIndexPointChart;
  bool get isLastSelectedPoint => _selectedIndexPointChart == 0;

  bool _hasModifiedData = false;
  bool get hasModifiedData => _hasModifiedData;
  set hasModifiedData(bool value) => _hasModifiedData = value;

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

  void _onThresholdFetched(
    BmiGetWeightThresholdEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiGetWeightThresholdState(Resource.loading()));
    final response = await _weightRepository.getWeightThreshold(
        // date: _currentTime.millisecondsSinceEpoch,
        // height: height,
        );

    response.when(
      success: (data) {
        _weightThreshold = data;
        emit(BmiGetWeightThresholdState(Resource.success(data)));
      },
      failure: (e) {
        emit(BmiGetWeightThresholdState(Resource.error(e)));
      },
    );
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

  void _onCheckWeightStatisticalDataExisted(
    BmiCheckStatisticalDataExistedEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiCheckStatisticalDataExistedState(Resource.loading()));

    final response = await _weightRepository.getWeightStatisticalData(
      currentTime: _currentTime.millisecondsSinceEpoch,
      periodFilterType: 5,
      page: 1,
    );

    response.when(
        success: (data) {
          bool hasData = data.trendItems?.isNotEmpty ?? false;
          _hasStatisticalData = hasData;
          preferences.setBool(Const.hasWeightRecord, hasData);
          emit(BmiCheckStatisticalDataExistedState(Resource.success(hasData)));
        },
        failure: (error) =>
            emit(BmiCheckStatisticalDataExistedState(Resource.error(error))));
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
      page: 1,
    );

    response.when(
        success: (data) {
          _weightStatistical = data;
          if (data.trendItems?.isNotEmpty ?? false) {
            // _selectedPointChart = DateTime.fromMillisecondsSinceEpoch(
            //     data.trendItems!.first.date! * 1000);
            preferences.setBool(Const.hasWeightRecord, true);
            add(BmiGetBmiStatisticalEvent());
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
        currentTime: _currentTime.millisecondsSinceEpoch,
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

    final response = await _weightRepository.getWeightLessons();
    final lessonsSupportResponse =
        await _weightRepository.getWeightLessonsSupport();

    response.when(
        success: (data) {
          _lessons = data;
          emit(BmiGetWeightLessonsState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetWeightLessonsState(Resource.error(error))));

    lessonsSupportResponse.when(
        success: (data) {
          _lessonsSupport = data;
          emit(BmiGetWeightLessonsState(Resource.success(data)));
        },
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
          if (_selectedPointChart == null) {
            _selectedPointChart = _historicalWeightList.firstOrNull;
            _selectedIndexPointChart = 0;
          }
          emit(BmiGetWeightIndexListState(Resource.success(data)));
        },
        failure: (error) =>
            emit(BmiGetWeightIndexListState(Resource.error(error))));
  }

  void _onUpdateWeightGoal(
    BmiUpdateWeightGoalEvent event,
    Emitter<BmiState> emit,
  ) async {
    emit(BmiUpdatedWeightGoalState(Resource.loading()));

    try {
      var currentGoal = await UserClient().fetchGoalInfo();
      final result = await UserClient().updateGoalInfo(currentGoal!.copyWith(
        goalWeight: event.weightGoal,
      ));

      emit(BmiUpdatedWeightGoalState(Resource.success(result)));
    } catch (err) {
      emit(BmiUpdatedWeightGoalState(Resource.error(err)));
    }
  }

  // public func
  void init() {
    _currentTime = DateTime.now();
    _periodType = BmiDateFilterType.aMonth;

    add(const BmiGetWeightThresholdEvent());
    add(const BmiInstructionFetchingEvent());
    add(const BmiGetWeightLessonsEvent());

    add(const BmiGetWeightStatisticalEvent());
    add(const BmiGetWaistStatisticalEvent());

    add(const BmiGetWeightRecordsEvent());

    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      add(const BmiGetAIAnalysicEvent());
      _hasInputedWaist = preferences.getBool(Const.hasInputedWaist) ?? false;
    });
  }

  void refresh() {
    add(BmiGetWeightStatisticalEvent());
    add(BmiGetWaistStatisticalEvent());
    add(const BmiCheckStatisticalDataExistedEvent());

    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      add(BmiGetAIAnalysicEvent());
      _hasInputedWaist = preferences.getBool(Const.hasInputedWaist) ?? false;
    });
  }

  // void checkRecordExistedWithEmit() {
  //   add(const BmiCheckStatisticalDataExistedEvent());
  // }

  void changePeriodTime(BmiDateFilterType period,
      {required bool isStatisticalView}) {
    if (period == _periodType) return;
    _periodType = period;
    if (isStatisticalView) {
      add(BmiGetBmiStatisticalEvent());
      // add(BmiGetWeightStatisticalEvent());
      // add(BmiGetWaistStatisticalEvent());
      add(BmiGetWeightRecordsEvent());
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

  void selectPointChart(int index) {
    var point = _historicalWeightList.elementAtOrNull(index);
    if (point == null) return;

    _selectedPointChart = point;
    _selectedIndexPointChart = index;
    add(BmiDataChangeEvent(
      BmiDataChangeEvent.selectedPointChanged,
      _selectedPointChart,
    ));
  }

  void backToPreviousPoint() {
    if (_selectedIndexPointChart == null) {
      return;
    }
    selectPointChart(_selectedIndexPointChart! + 1);
  }

  void goToNextPoint() {
    if (_selectedIndexPointChart == null || _selectedIndexPointChart! <= 0) {
      return;
    }
    selectPointChart(_selectedIndexPointChart! - 1);
  }

  void clearPoint() {
    _selectedIndexPointChart = null;
    _selectedPointChart = null;
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

  Future<void> updateGoalWeight({double? goal}) async {
    // add(BmiUpdateWeightGoalEvent(goal));
    weightGoal = goal;
  }

  String? getImageUrl(String? imgId) {
    if (imgId == null) {
      return null;
    } else if (Const.ENVIRONMENT_DEFAULT == 'product') {
      return Uri.https(Const.DOMAIN, 'App/Image/$imgId').toString();
    } else if (Const.ENVIRONMENT_DEFAULT == 'staging') {
      return Uri.https(Const.DOMAIN_STAGING, 'App/Image/$imgId').toString();
    } else {
      return Uri.https(Const.DOMAIN_DEV, 'App/Image/$imgId').toString();
    }
  }
}
