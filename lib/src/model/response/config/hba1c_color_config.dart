class Hba1cColorConfig {
  final int type;
  final String name;
  final String? fontColor;
  final String? fontBackground;
  final String background;
  final String? backgroundGradient1;
  final String? backgroundGradient2;

  Hba1cColorConfig({
    required this.type,
    required this.name,
    this.fontColor,
    this.fontBackground,
    required this.background,
    this.backgroundGradient1,
    this.backgroundGradient2,
  });

  factory Hba1cColorConfig.fromJson(Map<String, dynamic> json) {
    return Hba1cColorConfig(
      type: json['type'],
      name: json['name'],
      fontColor: json['fontColor'],
      fontBackground: json['fontBackground'],
      background: json['background'],
      backgroundGradient1: json['backgroundGradient1'],
      backgroundGradient2: json['backgroundGradient2'],
    );
  }
}
