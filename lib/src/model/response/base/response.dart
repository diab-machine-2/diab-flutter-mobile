import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

class ListResponse<T> {
  final List<T> data;
  final Meta? meta;

  ListResponse({required this.data, this.meta});

  factory ListResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ListResponse<T>(
      data: (json['data'] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class SingleResponse<T> {
  final T data;
  final Meta? meta;

  SingleResponse({required this.data, this.meta});

  factory SingleResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return SingleResponse<T>(
      data: fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  factory SingleResponse.fromJsonTypeString(Map<String, dynamic> json) {
    return SingleResponse(
      data: json['data'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

@JsonSerializable()
class Meta {
    @JsonKey(name: "success")
    final bool? success;

    Meta({
        this.success,
    });

    Meta copyWith({
        bool? success,
    }) => 
        Meta(
            success: success ?? this.success,
        );

    factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

    Map<String, dynamic> toJson() => _$MetaToJson(this);
}