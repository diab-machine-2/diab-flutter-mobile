class BloodPressureLesson {
  final String id;
  final String name;
  final int type;
  final String? imageUrl;

  BloodPressureLesson({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
  });

  factory BloodPressureLesson.fromJson(Map<String, dynamic> json) {
    return BloodPressureLesson(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      imageUrl: json['image'] != null ? json['image']['url'] : null,
    );
  }
}
