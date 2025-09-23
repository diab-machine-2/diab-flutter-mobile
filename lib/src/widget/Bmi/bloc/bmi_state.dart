import 'package:medical/src/service/resource.dart';
import 'package:medical/src/widget/bmi/models/weight_instruction_model.dart';

abstract class BmiState {
  const BmiState();
}

class BmiGetInstructionState extends BmiState {
  final Resource<List<WeightInstructionModel>> data;

  const BmiGetInstructionState(this.data);
}

class BmiDataChangedState extends BmiState {
  final String event;
  final dynamic data;

  const BmiDataChangedState(this.event, [this.data]);
}


class BmiGetWeightStatisticalState extends BmiState {
  const BmiGetWeightStatisticalState();
}

class BmiGetBmiStatisticalState extends BmiState {
  const BmiGetBmiStatisticalState();
}

class BmiGetWaistStatisticalState extends BmiState {
  const BmiGetWaistStatisticalState();
}