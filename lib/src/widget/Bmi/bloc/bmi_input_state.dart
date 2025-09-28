import 'package:medical/src/model/response/calculate_bmi_response.dart';
import 'package:medical/src/service/resource.dart';

abstract class BmiInputState {
  const BmiInputState();
}

class BmiInputInitialState extends BmiInputState {
  const BmiInputInitialState();
}

class BmiInputDataChangedState extends BmiInputState {
  final String event;
  final dynamic data;

  const BmiInputDataChangedState(this.event, [this.data]);
}

class BmiWaistValidatedState extends BmiInputState {
  const BmiWaistValidatedState(this.hasWaist);

  final bool hasWaist;
}

class BmiInputSubmitedState extends BmiInputState {
  final Resource<String> result;

  const BmiInputSubmitedState(this.result);
}

class BmiInputRecordDeletedState extends BmiInputState {
  final Resource<bool> result;

  const BmiInputRecordDeletedState(this.result);
}

class BmiInputErrorState extends BmiInputState {
  const BmiInputErrorState(this.error);

  final String error;
}

class BmiCalculatedState extends BmiInputState {
  const BmiCalculatedState(this.bmiModel);

  final Resource<CaculateBmiModel> bmiModel;
}
