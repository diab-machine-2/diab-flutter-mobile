import 'package:medical/src/model/request/revise_weight_record_request.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';

abstract class BmiInputEvent {
  const BmiInputEvent();
}

class BmiInputDataChangeEvent extends BmiInputEvent {
  final String event;
  final dynamic data;

  const BmiInputDataChangeEvent(this.event, [this.data]);

  static const String inputTimeChanged = "input_time_changed";
  static const String heightChanged = "height_changed";
  static const String weightChanged = "weight_changed";
  static const String waistChanged = "waist_changed";
  static const String noteChanged = "note_changed";
  static const String noteImagesChanged = "note_images_changed";
  static const String noteImagesFromRecordChanged =
      "note_images_from_record_changed";
}

class BmiWaistValidatingEvent extends BmiInputEvent {
  const BmiWaistValidatingEvent();
}

class BmiInputSubmitingEvent extends BmiInputEvent {
  final SubmitWeightRecordRequest request;

  const BmiInputSubmitingEvent(this.request);
}

class BmiInputRevisingEvent extends BmiInputEvent {
  final ReviseWeightRecordRequest request;

  const BmiInputRevisingEvent(this.request);
}

class BmiInputDeletingRecordEvent extends BmiInputEvent {

  const BmiInputDeletingRecordEvent();
}

class BmiInputErrorEvent extends BmiInputEvent {
  final String error;

  const BmiInputErrorEvent(this.error);
}

class BmiCalculatingEvent extends BmiInputEvent {
  const BmiCalculatingEvent();
}
