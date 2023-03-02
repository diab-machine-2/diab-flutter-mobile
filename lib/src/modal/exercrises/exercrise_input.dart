import 'package:meta/meta.dart';

@immutable
class InputDataExercriseModel {
  final int? date;
  final double? sumBurnedCalorie;
  final List<InputExercriseModel> exerciseInput;

  const InputDataExercriseModel({
    required this.date,
    required this.sumBurnedCalorie,
    required this.exerciseInput,
  });
  @override
  factory InputDataExercriseModel.fromJson(Map<String, dynamic> json) {
    return InputDataExercriseModel(
        date: json['date'],
        sumBurnedCalorie: json['sumBurnedCalorie'],
        exerciseInput: InputExercriseModel.toList(json['exerciseInput']));
  }

  static List<InputDataExercriseModel> toList(List<dynamic> items) {
    return items.map((item) => InputDataExercriseModel.fromJson(item)).toList();
  }
}

class InputExercriseModel {
  final String? id;
  final int? date;
  final double? burnedCalorie;
  final String? unit;
  final String? timeFrame;
  final List<ListExercriseModel> exercise;

  InputExercriseModel({
    required this.id,
    required this.date,
    required this.burnedCalorie,
    required this.unit,
    required this.timeFrame,
    required this.exercise,
  });
  @override
  factory InputExercriseModel.fromJson(Map<String, dynamic> json) {
    return InputExercriseModel(
        id: json['id'],
        date: json['date'],
        burnedCalorie: json['burnedCalorie'],
        unit: json['type'],
        timeFrame: json['timeFrame'],
        exercise: ListExercriseModel.toList(json['exercise']));
  }

  static List<InputExercriseModel> toList(List<dynamic> items) {
    return items.map((item) => InputExercriseModel.fromJson(item)).toList();
  }
}

class ListExercriseModel {
  final String? id;
  final String? category;
  final String? name;
  final double? duration;
  final double? burnedCalorie;
  final String? unit;
  final num? value;
  final ImagesUrlModel imageUrl;

  ListExercriseModel({
    required this.id,
    required this.category,
    required this.name,
    required this.duration,
    required this.burnedCalorie,
    required this.unit,
    required this.imageUrl,
    this.value,
  });
  @override
  factory ListExercriseModel.fromJson(Map<String, dynamic> json) {
    return ListExercriseModel(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      duration: json['duration'],
      burnedCalorie: json['burnedCalorie'],
      unit: json['unit'],
      value: json['value'],
      imageUrl: ImagesUrlModel.fromJson(json['imageUrl']),
    );
  }

  static List<ListExercriseModel> toList(List<dynamic> items) {
    return items.map((item) => ListExercriseModel.fromJson(item)).toList();
  }
}

class ImagesUrlModel {
  final String? id;
  final String? url;

  ImagesUrlModel({required this.id, required this.url});
  @override
  factory ImagesUrlModel.fromJson(Map<String, dynamic> json) {
    return ImagesUrlModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
