import 'package:intl/intl.dart';

class ReportData {
  ReportData({
    required this.title,
    required this.dateTime,
    required this.url,
  });
  final String title;
  final DateTime dateTime;
  final String url;

  String get time => DateFormat('dd-MM-yyy').format(dateTime);
}
