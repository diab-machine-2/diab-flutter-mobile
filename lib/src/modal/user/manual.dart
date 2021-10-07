import 'package:meta/meta.dart';

class ManualModel {
  final String? id;
  final String? question;
  final String? answer;

  ManualModel(
      {required this.id, required this.question, required this.answer});

  factory ManualModel.fromJson(Map<String, dynamic> json) {
    return ManualModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }

  static List<ManualModel> toList(List<dynamic> items) {
    return items.map((item) => ManualModel.fromJson(item)).toList();
  }
}
