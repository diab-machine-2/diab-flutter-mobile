import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/weight_repository.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi/bloc/bmi_input_state.dart';
import 'dart:math' as math;

class BmiInputBloc extends Bloc<BmiInputEvent, BmiInputState> {
  BmiInputBloc(WeightRepository weightRepository)
      : _weightRepository = weightRepository,
        super(BmiInputInitialState()) {
    on<BmiInputDataChangeEvent>(_onDataChanged);
    on<BmiWaistValidatingEvent>(_onWaistValidated);
    on<BmiInputSubmitingEvent>(_onWeightSubmitted);
  }

  final WeightRepository _weightRepository;

  DateTime? _currentInputTime;
  DateTime? get currentInputTime => _currentInputTime;
  set currentInputTime(DateTime? time) {
    _currentInputTime = time;
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.inputTimeChanged,
      time,
    ));
  }

  double _currentHeight = 0;
  double get currentHeight => _currentHeight;
  set currentHeight(double value) {
    _currentHeight = value;
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.heightChanged,
      value,
    ));
  }

  double _weight = 0.0;
  double get weight => _weight;
  set weight(double value) {
    _weight = value;
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.weightChanged,
      value,
    ));
  }

  double get bmi {
    if (_currentHeight == 0) return 0;

    double heightInMeter = _currentHeight / 100;
    double bmi = _weight / (math.pow(heightInMeter, 2));
    return double.parse(bmi.toStringAsFixed(1));
  }

  double _waist = 0.0;
  double get waist => _waist;
  set waist(double value) {
    _waist = value;
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.waistChanged,
      value,
    ));
  }

  String _note = "";
  String get note => _note;
  set note(String value) => _note = value;

  List<String> _noteImages = [];
  List<String> get noteImages => _noteImages;

  // Handle event

  void _onDataChanged(
    BmiInputDataChangeEvent event,
    Emitter<BmiInputState> emit,
  ) {
    emit(BmiInputDataChangedState(event.event, event.data));
  }

  void _onWaistValidated(
    BmiWaistValidatingEvent event,
    Emitter<BmiInputState> emit,
  ) {
    emit(BmiWaistValidatedState(_waist != 0.0));
  }

  void _onWeightSubmitted(
    BmiInputSubmitingEvent event,
    Emitter<BmiInputState> emit,
  ) async {
    emit(BmiInputSubmitedState(Resource.loading()));

    final result = await _weightRepository.submitWeightRecord(event.request);
    result.when(
      success: (data) => emit(BmiInputSubmitedState(Resource.success(data))),
      failure: (error) => emit(BmiInputSubmitedState(Resource.error(error))),
    );
  }

  //

  void addImages(List<String> paths) {
    _noteImages.addAll(paths);
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.noteImagesChanged,
      _noteImages,
    ));
  }

  void removeImage(String path) {
    _noteImages.remove(path);
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.noteImagesChanged,
      _noteImages,
    ));
  }

  void validateWaist() {
    add(BmiWaistValidatingEvent());
  }

  void submitWeightRecord() {
    SubmitWeightRecordRequest request = SubmitWeightRecordRequest.create(
      date: _currentInputTime!.millisecondsSinceEpoch,
      weight: _weight,
      height: _currentHeight,
      waist: _waist,
      note: _note,
      images: _noteImages,
    );

    add(BmiInputSubmitingEvent(request));
  }
}
