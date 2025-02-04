class Specialty {
  final String name;
  final String? shortended;
  final int id;
  final String banner;
  final String image;

  Specialty({
    required this.name,
    this.shortended,
    required this.id,
    required this.banner,
    required this.image,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      name: json['name'],
      shortended: json['shortended'],
      id: json['id'],
      banner: json['banner'],
      image: json['image'],
    );
  }
}