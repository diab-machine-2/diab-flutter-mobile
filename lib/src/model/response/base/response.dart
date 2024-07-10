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

class Meta {
  final bool success;
  Meta({required this.success});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      success: json['success'],
    );
  }
}
