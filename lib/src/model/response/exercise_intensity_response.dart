class ExerciseIntensityResponse {
  final Meta? meta;
  final List<ExerciseIntensity>? data;

  ExerciseIntensityResponse({
    this.meta,
    this.data,
  });

  factory ExerciseIntensityResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseIntensityResponse(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ExerciseIntensity.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (meta != null) {
      result['meta'] = meta!.toJson();
    }
    if (data != null) {
      result['data'] = data!.map((e) => e.toJson()).toList();
    }
    return result;
  }
}

class Meta {
  final bool? success;
  final String? message;

  Meta({
    this.success,
    this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (success != null) {
      result['success'] = success;
    }
    if (message != null) {
      result['message'] = message;
    }
    return result;
  }
}

class ExerciseIntensity {
  final String intensityId;
  final String name;

  ExerciseIntensity({
    required this.intensityId,
    required this.name,
  });

  factory ExerciseIntensity.fromJson(Map<String, dynamic> json) {
    return ExerciseIntensity(
      intensityId: json['intensityId'] ?? json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intensityId': intensityId,
      'name': name,
    };
  }
}
