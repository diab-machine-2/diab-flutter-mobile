class GlucoseLesson {
  final String id;
  final String name;
  final int type;
  final String? imageUrl;

  GlucoseLesson({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
  });

  factory GlucoseLesson.fromJson(Map<String, dynamic> json) {
    return GlucoseLesson(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      imageUrl: json['image'] != null ? json['image']['url'] : null,
    );
  }
}
