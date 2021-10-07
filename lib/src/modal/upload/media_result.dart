import 'package:meta/meta.dart';

class MediaResultModel {
  final String? fileName;
  final String? mimeType;
  final int? size;
  final String? link;

  MediaResultModel(
      {required this.fileName,
      required this.mimeType,
      required this.size,
      required this.link});

  factory MediaResultModel.fromJson(Map<String, dynamic> json) {
    return MediaResultModel(
        fileName: json['file_name'],
        mimeType: json['mime_type'],
        size: json['size'],
        link: json['link']);
  }

  static List<MediaResultModel> toList(List<dynamic> items) {
    return items.map((item) => MediaResultModel.fromJson(item)).toList();
  }
}
