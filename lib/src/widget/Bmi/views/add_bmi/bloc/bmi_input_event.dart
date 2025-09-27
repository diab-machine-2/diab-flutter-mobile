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
  static const String noteImagesChanged = "note_images_changed";
}

class BmiWaistValidatingEvent extends BmiInputEvent {
  const BmiWaistValidatingEvent();
}

class BmiInputSubmitingEvent extends BmiInputEvent {
  final SubmitWeightRecordRequest request;
  
  const BmiInputSubmitingEvent(this.request);
}
