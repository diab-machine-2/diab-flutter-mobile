class BmiColorConfig {
  final String id;
  final double from;
  final double to;
  final String type;
  final String description;
  final String colorCode;
  final String backgroundColorCode;
  final String textcolorCode;

  BmiColorConfig({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.description,
    required this.colorCode,
    required this.backgroundColorCode,
    required this.textcolorCode,
  });

  factory BmiColorConfig.fromJson(Map<String, dynamic> json) {
    return BmiColorConfig(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      type: json['type'],
      description: json['description'],
      colorCode: json['colorCode'],
      backgroundColorCode: json['backgroundColorCode'],
      textcolorCode: json['textcolorCode'],
    );
  }
}
