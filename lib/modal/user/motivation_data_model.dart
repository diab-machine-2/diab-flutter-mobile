import 'package:medical/modal/user/motivation_model.dart';
import 'package:meta/meta.dart';

class MotivationDataModel {
  final List<MotivationModel> models;
  final bool hasMore;

  MotivationDataModel({@required this.models, @required this.hasMore});
}
