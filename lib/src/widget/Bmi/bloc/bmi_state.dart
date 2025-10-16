import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/widget/Bmi/models/weight_instruction_model.dart';

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

// statistical

class BmiGetWeightStatisticalState extends BmiState {
  const BmiGetWeightStatisticalState(this.data);

  final Resource<BmiWeightStatistical> data;
}

class BmiGetBmiStatisticalState extends BmiState {
  const BmiGetBmiStatisticalState(this.data);

  final Resource<BmiStatistical> data;
}

class BmiGetWaistStatisticalState extends BmiState {
  const BmiGetWaistStatisticalState(this.data);

  final Resource<BmiWaistStatistical> data;
}

class BmiCheckStatisticalDataExistedState extends BmiState {
  const BmiCheckStatisticalDataExistedState(this.data);

  final Resource<bool> data;
}

// weight index

class BmiGetWeightIndexListState extends BmiState {
  const BmiGetWeightIndexListState(this.data);

  final Resource<BmiGetWeightListResponse> data;
}

// others data

class BmiGetWeightLessonsState extends BmiState {
  const BmiGetWeightLessonsState(this.data);

  final Resource<List<BmiWeightLesson>> data;
}

class BmiGetAIAnalysicState extends BmiState {
  const BmiGetAIAnalysicState(this.data);

  final Resource<String> data;
}

class BmiGetAIIndexAnalysicState extends BmiState {
  const BmiGetAIIndexAnalysicState(this.data);

  final Resource<String> data;
}

class BmiUpdatedWeightGoalState extends BmiState {
  const BmiUpdatedWeightGoalState(this.result);

  final Resource<bool> result;
}
