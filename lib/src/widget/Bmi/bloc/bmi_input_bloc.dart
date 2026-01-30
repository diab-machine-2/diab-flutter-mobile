import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/weight_repository.dart';
import 'package:medical/src/model/request/revise_weight_record_request.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/calculate_bmi_response.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';

class BmiInputBloc extends Bloc<BmiInputEvent, BmiInputState> {
  BmiInputBloc(WeightRepository weightRepository)
      : _weightRepository = weightRepository,
        super(BmiInputInitialState()) {
    on<BmiInputDataChangeEvent>(_onDataChanged);
    on<BmiWaistValidatingEvent>(_onWaistValidated);
    on<BmiInputSubmitingEvent>(_onWeightSubmitted);
    on<BmiInputRevisingEvent>(_onWeightRevised);
    on<BmiInputDeletingRecordEvent>(_onWeightDeleted);
    on<BmiInputErrorEvent>(_onError);
    on<BmiCalculatingEvent>(_onBmiCalculated);
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
  set weightWithoutEmit(double value) {
    _weight = value;
  }

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
  set waistWithoutEmit(double value) {
    _waist = value;
  }

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

  CaculateBmiModel? _calculatedBmi;
  CaculateBmiModel? get calculatedBmi => _calculatedBmi;

  String? _currentRecordId;

  String? _goalId;
  String? get goalId => _goalId;
  set goalId(String? value) => _goalId = value;

  List<String> _removalNoteImages = [];
  List<String> get removalNoteImages => _removalNoteImages;

  // url img
  List<WeightRecordImage> _noteImagesFromRecord = [];
  List<WeightRecordImage> get noteImagesFromRecord => _noteImagesFromRecord;

  int? getThresholdIndex() {
    if (_calculatedBmi?.bmi != null) {
      double bmi = _calculatedBmi!.bmi!;
      var threshold = Const.bmiThreshold;
      for (int i = 0; i < threshold.length - 1; i++) {
        if (bmi > threshold[i] && bmi <= threshold[i + 1]) {
          return i + 1;
        } else if (bmi <= threshold.first) {
          return 0;
        } else if (bmi > threshold.last) {
          return threshold.length;
        }
      }
      return null;
    }
    return null;
  }
  // Handle event

  void _onDataChanged(
    BmiInputDataChangeEvent event,
    Emitter<BmiInputState> emit,
  ) {
    emit(BmiInputDataChangedState(event.event, event.data));
  }

  void _onError(
    BmiInputErrorEvent event,
    Emitter<BmiInputState> emit,
  ) {
    emit(BmiInputErrorState(event.error));
  }

  void _onWaistValidated(
    BmiWaistValidatingEvent event,
    Emitter<BmiInputState> emit,
  ) {
    emit(BmiWaistValidatedState(_waist != 0.0));
  }

  void _onBmiCalculated(
    BmiCalculatingEvent event,
    Emitter<BmiInputState> emit,
  ) async {
    emit(BmiCalculatedState(Resource.loading()));

    final result = await _weightRepository.calculateBmi(
      weight: _weight,
      height: _currentHeight.toInt(),
    );
    result.when(
      success: (data) {
        _calculatedBmi = data;
        emit(BmiCalculatedState(Resource.success(data)));
      },
      failure: (error) => emit(BmiCalculatedState(Resource.error(error))),
    );
  }

  void _onWeightSubmitted(
    BmiInputSubmitingEvent event,
    Emitter<BmiInputState> emit,
  ) async {
    emit(BmiInputSubmitedState(Resource.loading()));

    // Convert images to JPEG format (handles HEIC/HEIF from iOS)
    List<String>? convertedImages;
    if (event.request.images != null && event.request.images!.isNotEmpty) {
      convertedImages = await Utils.convertImagesToJpeg(event.request.images!);
    }

    // Create new request with converted images
    final requestWithConvertedImages = event.request.copyWith(
      images: convertedImages,
    );

    final result = await _weightRepository.submitWeightRecord(requestWithConvertedImages);
    result.when(
      success: (data) => {
        PhoneValidationManager.setShouldShowPhoneValidation(),
        if (_goalId != null && _goalId!.isNotEmpty)
          {
            HomeClient().completeSmartGoal(
              DateTime.fromMillisecondsSinceEpoch(event.request.date),
              _goalId!,
              1,
              ScheduleType.weight.typeIndex,
            )
          },
        emit(BmiInputSubmitedState(Resource.success(data.data))),
      },
      failure: (error) => emit(BmiInputSubmitedState(Resource.error(error))),
    );
  }

  void _onWeightRevised(
    BmiInputRevisingEvent event,
    Emitter<BmiInputState> emit,
  ) async {
    emit(BmiInputSubmitedState(Resource.loading()));

    // Convert images to JPEG format (handles HEIC/HEIF from iOS)
    List<String>? convertedImages;
    if (event.request.images != null && event.request.images!.isNotEmpty) {
      convertedImages = await Utils.convertImagesToJpeg(event.request.images!);
    }

    // Create new request with converted images
    final requestWithConvertedImages = event.request.copyWith(
      images: convertedImages,
    );

    final result = await _weightRepository.reviseWeightRecord(requestWithConvertedImages);
    result.when(
      success: (data) =>
          emit(BmiInputSubmitedState(Resource.success(data.data))),
      failure: (error) => emit(BmiInputSubmitedState(Resource.error(error))),
    );
  }

  void _onWeightDeleted(
    BmiInputDeletingRecordEvent event,
    Emitter<BmiInputState> emit,
  ) async {
    emit(BmiInputRecordDeletedState(Resource.loading()));

    final result =
        await _weightRepository.deleteWeightRecord(id: _currentRecordId!);
    result.when(
      success: (data) =>
          emit(BmiInputRecordDeletedState(Resource.success(data))),
      failure: (error) =>
          emit(BmiInputRecordDeletedState(Resource.error(error))),
    );
  }

  //

  void addImages(List<String> paths) {
    const int maxImages = 5;
    final int currentTotalImages =
        _noteImages.length + _noteImagesFromRecord.length;
    final int remainingSlots = maxImages - currentTotalImages;

    if (remainingSlots <= 0) {
      return; // Already at max capacity
    }

    // Only add images up to the remaining slots
    final List<String> imagesToAdd = paths.take(remainingSlots).toList();
    _noteImages.addAll(imagesToAdd);
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

  void removeRecordImage(WeightRecordImage img) {
    _noteImagesFromRecord.remove(img);
    _removalNoteImages.add(img.id!);
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.noteImagesFromRecordChanged,
      _noteImagesFromRecord,
    ));
  }

  void error(String error) {
    add(BmiInputErrorEvent(error));
  }

  void validate(bool hasInputedWaist) {
    if (_weight <= 0) {
      error("Vui lòng nhập cân nặng");
    } else if (_waist != 0 && (_waist < 1 || _waist > 999)) {
      error("Vui lòng nhập vòng eo hợp lệ");
    } else if (!hasInputedWaist) {
      add(BmiWaistValidatingEvent());
    } else {
      submitWeightRecord();
    }
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
    add(BmiCalculatingEvent());
  }

  void reviseWeightRecord() {
    ReviseWeightRecordRequest request = ReviseWeightRecordRequest.create(
      id: _currentRecordId!,
      date: _currentInputTime!.millisecondsSinceEpoch,
      weight: _weight,
      height: _currentHeight,
      waist: _waist,
      note: _note,
      images: _noteImages,
      removalImageIds: _removalNoteImages,
    );

    add(BmiInputRevisingEvent(request));
    add(BmiCalculatingEvent());
  }

  void deleteWeightRecord() {
    add(BmiInputDeletingRecordEvent());
  }

  void clear() {
    _weight = 0;
    _waist = 0;
    _note = "";
    _noteImages.clear();
  }

  void initRevisingData(BmiGetWeightRecord record) {
    _currentRecordId = record.id;
    _weight = record.weight ?? 0;
    _waist = record.waist ?? 0;
    _currentHeight = record.height ?? 0;
    _note = record.note ?? "";
    _noteImagesFromRecord = List.from(record.images ?? []);
    _currentInputTime =
        DateTime.fromMillisecondsSinceEpoch(record.date! * 1000);
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.weightChanged,
      _weight,
    ));
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.waistChanged,
      _waist,
    ));
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.noteChanged,
      _note,
    ));
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.noteImagesFromRecordChanged,
      _noteImagesFromRecord,
    ));
    add(BmiInputDataChangeEvent(
      BmiInputDataChangeEvent.inputTimeChanged,
      _currentInputTime,
    ));
  }
}
