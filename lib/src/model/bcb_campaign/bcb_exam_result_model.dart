class BcbExamResultModel {
  String? id;
  String? fileUrl;
  String? additionalServices;
  DateTime? uploadedAt;
  DateTime? viewedAt;

  BcbExamResultModel({
    this.id,
    this.fileUrl,
    this.additionalServices,
    this.uploadedAt,
    this.viewedAt,
  });

  factory BcbExamResultModel.fromJson(Map<String, dynamic> json) {
    return BcbExamResultModel(
      id: json['id'] as String?,
      fileUrl: json['fileUrl'] as String?,
      additionalServices: json['additionalServices'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
      viewedAt: json['viewedAt'] != null
          ? DateTime.tryParse(json['viewedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'additionalServices': additionalServices,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'viewedAt': viewedAt?.toIso8601String(),
    };
  }
}
