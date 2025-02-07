class SearchBookingClinicListRequest {
  final String type;
  final String language;
  final String urlKeyword;
  final String specialty;
  final String name;
  final String keyword;
  final String page;
  final String svAvailable;
  final String sellType;
  final String parentTerm;
  final String lng;
  final String lat;

  SearchBookingClinicListRequest({
    this.type = 'location',
    this.language = 'vi',
    this.urlKeyword = '',
    this.specialty = '',
    this.name = '',
    this.keyword = '',
    this.page = '1',
    this.svAvailable = '',
    this.sellType = '',
    this.parentTerm = '',
    this.lng = '',
    this.lat = '',
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'language': language,
        'url_keyword': urlKeyword,
        'specialty': specialty,
        'name': name,
        'keyword': keyword,
        'page': page,
        'sv_available': svAvailable,
        'sell_type': sellType,
        'parent_term': parentTerm,
        'lng': lng,
        'lat': lat,
      };

  SearchBookingClinicListRequest copyWith({
    String? type,
    String? language,
    String? urlKeyword,
    String? specialty,
    String? name,
    String? keyword,
    dynamic page,
    String? svAvailable,
    String? sellType,
    String? parentTerm,
    String? lng,
    String? lat,
  }) {
    return SearchBookingClinicListRequest(
      type: type ?? this.type,
      language: language ?? this.language,
      urlKeyword: urlKeyword ?? this.urlKeyword,
      specialty: specialty ?? this.specialty,
      name: name ?? this.name,
      keyword: keyword ?? this.keyword,
      page: page?.toString() ?? this.page,
      svAvailable: svAvailable ?? this.svAvailable,
      sellType: sellType ?? this.sellType,
      parentTerm: parentTerm ?? this.parentTerm,
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
    );
  }
}
