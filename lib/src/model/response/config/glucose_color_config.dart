class GlucoseColorConfig {
  final int type;
  final String name;
  final String background;

  GlucoseColorConfig({
    required this.type,
    required this.name,
    required this.background,
  });

  factory GlucoseColorConfig.fromJson(Map<String, dynamic> json) {
    return GlucoseColorConfig(
      type: json['type'],
      name: json['name'],
      background: json['background'],
    );
  }
}
