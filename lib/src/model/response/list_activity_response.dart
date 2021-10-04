import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'meta.dart';

class ListActivityResponse {
  ListActivityResponse({
    Meta? meta,
    List<ExerciseIntensityModel>? data,}){
    _meta = meta;
    _data = data;
  }

  ListActivityResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ExerciseIntensityModel.fromJson(v));
      });
    }
  }
  Meta? _meta;
  List<ExerciseIntensityModel>? _data;

  Meta? get meta => _meta;
  List<ExerciseIntensityModel>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

