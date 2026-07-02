class ClinicSpecialty {
  final String name;
  final String? shortended;
  final int id;
  final String? banner;
  final String? image;
  final List<int> clinic_ids;
  final List<int> telemedicine_clinic_ids;

  ClinicSpecialty({
    required this.name,
    this.shortended,
    required this.id,
    this.banner,
    this.image,
    this.clinic_ids = const [],
    this.telemedicine_clinic_ids = const [],
  });

  factory ClinicSpecialty.fromJson(Map<String, dynamic> json) {
    return ClinicSpecialty(
      name: json['name'],
      shortended: json['shortended'],
      id: json['id'],
      banner: json['banner'],
      image: json['image'],
      clinic_ids: (json['clinic_ids'] as List?)?.map((e) => e as int).toList() ?? [],
      telemedicine_clinic_ids: (json['telemedicine_clinic_ids'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }
}
