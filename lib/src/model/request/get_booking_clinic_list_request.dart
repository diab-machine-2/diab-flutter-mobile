class SearchBookingClinicListRequest {
  final String type;
  final String language;
  final List<String> urlKeywords;
  final String specialty;
  final String name;
  final String keyword;
  final String page;
  final List<String> svAvailable;
  final String sellType;
  final String parentTerm;
  final String lng;
  final String lat;
  final String kind; // clinic, doctor
  final List<String> timeframes; // weekend, weekday, after_hours
  final List<String> clinicTypes; // clinic, hospital, public_hospital, lab
  final int isFilterDistance;

  SearchBookingClinicListRequest({
    this.type = 'location',
    this.language = 'vi',
    this.urlKeywords = const [],
    this.specialty = '',
    this.name = '',
    this.keyword = '',
    this.page = '1',
    this.svAvailable = const [],
    this.sellType = '',
    this.parentTerm = '',
    this.lng = '',
    this.lat = '',
    this.kind = 'clinic',
    this.timeframes = const [],
    this.clinicTypes = const [],
    this.isFilterDistance = 1,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'language': language,
        'url_keywords': urlKeywords,
        'specialty': specialty,
        'name': name,
        'keyword': keyword,
        'page': page,
        'sv_available': svAvailable,
        'sell_type': sellType,
        'parent_term': parentTerm,
        'lng': lng,
        'lat': lat,
        'kind': kind,
        'timeframes': timeframes,
        'clinic_types': clinicTypes,
        'is_filter_distance': isFilterDistance,
      };

  SearchBookingClinicListRequest copyWith({
    String? type,
    String? language,
    List<String>? urlKeywords,
    String? specialty,
    String? name,
    String? keyword,
    dynamic page,
    List<String>? svAvailable,
    String? sellType,
    String? parentTerm,
    String? lng,
    String? lat,
    String? kind,
    List<String>? timeframes,
    List<String>? clinicTypes,
    int? isFilterDistance,
  }) {
    return SearchBookingClinicListRequest(
      type: type ?? this.type,
      language: language ?? this.language,
      urlKeywords: urlKeywords ?? this.urlKeywords,
      specialty: specialty ?? this.specialty,
      name: name ?? this.name,
      keyword: keyword ?? this.keyword,
      page: page?.toString() ?? this.page,
      svAvailable: svAvailable ?? this.svAvailable,
      sellType: sellType ?? this.sellType,
      parentTerm: parentTerm ?? this.parentTerm,
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
      kind: kind ?? this.kind,
      timeframes: timeframes ?? this.timeframes,
      clinicTypes: clinicTypes ?? this.clinicTypes,
      isFilterDistance: isFilterDistance ?? this.isFilterDistance,
    );
  }
}
