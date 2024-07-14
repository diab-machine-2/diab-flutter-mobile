class BloodPressureColorConfig {
  final int type;
  final String name;
  final String? fontColor;
  final String background;

  BloodPressureColorConfig({
    required this.type,
    required this.name,
    this.fontColor,
    required this.background,
  });

  factory BloodPressureColorConfig.fromJson(Map<String, dynamic> json) {
    return BloodPressureColorConfig(
      type: json['type'],
      name: json['name'],
      fontColor: json['fontColor'],
      background: json['background'],
    );
  }
}
