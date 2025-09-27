import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
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
  final Resource<CommonResponse> result;

  const BmiInputSubmitedState(this.result);
}
