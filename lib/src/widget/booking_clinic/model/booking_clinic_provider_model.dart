class BookingClinicProvider {
  final int id;
  final String name;
  final String? address;
  final List<ServiceAvailable> svAvailable;
  final String status;
  final String avatar;
  final String language;
  final String isSuper;
  final String kind;
  final int? numApt;
  final double? star;
  final List<Specialty> specialty;
  final ClinicSchedule? schedule;
  final List<ClinicService> service;
  final String tagLine;
  final int? verify;
  final String subscriberType;
  final String? clinicType;
  final String shortAddress;
  final String nameNoaccent;
  final int? isAvailableSchedule;
  final int? isSale;
  final double? lat;
  final double? lng;

  BookingClinicProvider({
    required this.id,
    required this.name,
    this.address,
    required this.svAvailable,
    this.status = '',
    this.avatar = '',
    this.language = '',
    this.isSuper = '',
    this.kind = '',
    this.numApt,
    this.star,
    required this.specialty,
    this.schedule,
    required this.service,
    this.tagLine = '',
    this.verify,
    this.subscriberType = '',
    this.clinicType,
    this.shortAddress = '',
    this.nameNoaccent = '',
    this.isAvailableSchedule,
    this.isSale,
    this.lat,
    this.lng,
  });

  factory BookingClinicProvider.fromJson(Map<String, dynamic> json) {
    return BookingClinicProvider(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      name: json['name'],
      address: json['address'],
      svAvailable: json['sv_available'] != null
          ? (json['sv_available'] as List)
              .map((e) => ServiceAvailable.fromJson(e))
              .toList()
          : [],
      status: json['status'] ?? '',
      avatar: json['avatar'] ?? '',
      language: json['language'] ?? '',
      isSuper: json['is_super'] ?? '',
      kind: json['kind'] ?? '',
      numApt: json['num_apt'] is String
          ? int.tryParse(json['num_apt'])
          : json['num_apt'],
      star: parseStarRating(json['star']),
      specialty: json['specialty'] != null
          ? (json['specialty'] as List)
              .map((e) => Specialty.fromJson(e))
              .toList()
          : [],
      schedule: json['schedule'] is List || json['schedule'] == null
          ? null
          : ClinicSchedule.fromJson(json['schedule']),
      service: json['service'] != null
          ? (json['service'] as List)
              .map((e) => ClinicService.fromJson(e))
              .toList()
          : [],
      tagLine: json['tag_line'] ?? '',
      verify: json['verify'] is String
          ? int.tryParse(json['verify'])
          : json['verify'],
      subscriberType: json['subscriber_type'] ?? '',
      clinicType: json['clinic_type'],
      shortAddress: json['short_address'] ?? '',
      nameNoaccent: json['name_noaccent'] ?? '',
      isAvailableSchedule: json['is_available_schedule'] is String
          ? int.tryParse(json['is_available_schedule'])
          : json['is_available_schedule'],
      isSale: json['is_sale'] is String
          ? int.tryParse(json['is_sale'])
          : json['is_sale'],
      lat: json['lat'] is String
          ? double.tryParse(json['lat']) ?? 0.0
          : (json['lat']?.toDouble() ?? 0.0),
      lng: json['lng'] is String
          ? double.tryParse(json['lng']) ?? 0.0
          : (json['lng']?.toDouble() ?? 0.0),
    );
  }

  static double? parseStarRating(dynamic value) {
    if (value == null || value == '') return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class ServiceAvailable {
  final String key;
  final String name;

  ServiceAvailable({required this.key, required this.name});

  factory ServiceAvailable.fromJson(Map<String, dynamic> json) {
    return ServiceAvailable(
      key: json['key'],
      name: json['name'],
    );
  }
}

class Specialty {
  final int specialtyId;
  final String name;

  Specialty({required this.specialtyId, required this.name});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      specialtyId: json['specialty_id'],
      name: json['name'],
    );
  }
}

class ClinicService {
  final String name;
  final String type;
  final String id;
  final int fromPrice;
  final String price;

  ClinicService({
    required this.name,
    required this.type,
    required this.id,
    required this.fromPrice,
    required this.price,
  });

  factory ClinicService.fromJson(Map<String, dynamic> json) {
    return ClinicService(
      name: json['name'],
      type: json['type'],
      id: json['id'],
      fromPrice: json['from_price'],
      price: json['price'],
    );
  }
}

class ClinicSchedule {
  final Map<String, Map<String, int>> weekDays;
  final OpenHour? openHour;

  ClinicSchedule({required this.weekDays, required this.openHour});

  factory ClinicSchedule.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, int>> weekDays = {};
    ['mon', 'tue', 'wed', 'thurs', 'fri', 'sat', 'sun'].forEach((day) {
      if (json[day] != null) {
        weekDays[day] = Map<String, int>.from(json[day]);
      }
    });

    return ClinicSchedule(
      weekDays: weekDays,
      openHour: json['open_hour'] == null
          ? null
          : OpenHour.fromJson(json['open_hour']),
    );
  }
}

class OpenHour {
  final Map<String, DaySchedule> days;

  OpenHour({required this.days});

  factory OpenHour.fromJson(Map<String, dynamic> json) {
    Map<String, DaySchedule> days = {};
    json.forEach((key, value) {
      days[key] = DaySchedule.fromJson(value);
    });
    return OpenHour(days: days);
  }
}

class DaySchedule {
  final int isWork;
  final String? openTime;
  final String? closeTime;

  DaySchedule({
    required this.isWork,
    this.openTime,
    this.closeTime,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isWork: json['is_work'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }
}
