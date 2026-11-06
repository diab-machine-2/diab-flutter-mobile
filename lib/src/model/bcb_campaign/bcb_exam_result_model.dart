class BcbExamResultModel {
  String? id;
  String? fileUrl;
  String? additionalServices;
  DateTime? uploadedAt;
  DateTime? viewedAt;
  int? type;

  /// The backend sent a `viewedAt` key (BE-2). Older backends leave it out,
  /// and then a null `viewedAt` says nothing about whether it was read.
  final bool tracksViewed;

  /// Not opened yet, as far as the backend tracks it.
  bool get isUnviewed => tracksViewed && viewedAt == null;

  BcbExamResultModel({
    this.id,
    this.fileUrl,
    this.additionalServices,
    this.uploadedAt,
    this.viewedAt,
    this.type,
    this.tracksViewed = false,
  });

  factory BcbExamResultModel.fromJson(Map<String, dynamic> json) {
    return BcbExamResultModel(
      id: json['id'] as String?,
      fileUrl: json['fileUrl'] as String?,
      additionalServices: json['additionalServices'] as String?,
      uploadedAt: _parseDateTime(json['uploadedAt']),
      viewedAt: _parseDateTime(json['viewedAt']),
      type: json['type'] as int?,
      tracksViewed: json.containsKey('viewedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'additionalServices': additionalServices,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'viewedAt': viewedAt?.toIso8601String(),
      'type': type,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
    }
    if (value is String) {
      final unix = int.tryParse(value);
      if (unix != null) {
        return DateTime.fromMillisecondsSinceEpoch(unix * 1000);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<BcbExamResultModel> listFrom(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(BcbExamResultModel.fromJson)
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      return [BcbExamResultModel.fromJson(raw)];
    }
    return [];
  }
}
