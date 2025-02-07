class ClinicSpecialty {
  final String name;
  final String? shortended;
  final int id;
  final String? banner;
  final String? image;

  ClinicSpecialty({
    required this.name,
    this.shortended,
    required this.id,
    this.banner,
    this.image,
  });

  factory ClinicSpecialty.fromJson(Map<String, dynamic> json) {
    return ClinicSpecialty(
      name: json['name'],
      shortended: json['shortended'],
      id: json['id'],
      banner: json['banner'],
      image: json['image'],
    );
  }
}
