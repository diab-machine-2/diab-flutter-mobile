class ExerciseCategoryResponse {
  final Meta? meta;
  final List<ExerciseCategory>? data;

  ExerciseCategoryResponse({
    this.meta,
    this.data,
  });

  factory ExerciseCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryResponse(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ExerciseCategory.fromJson(e))
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

class ExerciseCategory {
  final String categoryId;
  final String name;

  ExerciseCategory({
    required this.categoryId,
    required this.name,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      categoryId: json['categoryId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
    };
  }
}
