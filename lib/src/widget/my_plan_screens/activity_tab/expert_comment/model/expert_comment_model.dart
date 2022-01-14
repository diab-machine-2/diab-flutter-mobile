import 'package:medical/src/utils/date_utils.dart';

class ExpertCommentModel {
  ExpertCommentModel({
    required this.name,
    required this.role,
    required this.comment,
    required this.dateTime,
    required this.url,
  });

  final String url;
  final String name;
  final String role;
  final String comment;
  final String dateTime;

  DateTime? get time => DateUtil.parseStringToDate(dateTime, 'dd/MM/yyyy');
}
