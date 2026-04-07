class ImageNoteModel {
  final int order;
  final String id;

  ImageNoteModel({
    required this.order,
    required this.id,
  });

  factory ImageNoteModel.fromJson(Map<String, dynamic> json) {
    return ImageNoteModel(
      order: json['order'] ?? 0,
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'Order': order,
    'Id': id,
  };

  static List<ImageNoteModel> fromJsonList(List<dynamic>? jsonList) {
    if (jsonList == null) return [];
    return jsonList
        .map((e) => ImageNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}