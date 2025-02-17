import 'package:easy_localization/easy_localization.dart';

class DsmesClinicModel {
  final int id;
  final String name;
  final List<String> language;
  final String address;
  final String phone;
  final String introduction;
  final List<SpecialtyDetail> specialty;
  final String avatar;
  final String lat;
  final String lng;
  final String? servicesImage;
  final String isSuper;
  final String status;
  final int serviceId;
  // final String insurance;
  final String tagLine;
  final Map<String, int> showGoodAt;
  final Map<String, List<GoodAt>> goodAt;
  final List<GoodAt> defaultGoodAt;
  final int clinicId;
  final List<dynamic> serviceType;
  final ServiceList serviceList;
  final Map<String, Map<String, int>> schedule;
  final String aptInterval;
  final List<ExtraAvatar> extraAvatar;
  final List<ServiceAvailable> svAvailable; // 'at_clinic', 'telemedicine', 'at_home'
  final String profileType; // 'booking' or 'premium'

  DsmesClinicModel({
    required this.id,
    required this.name,
    required this.language,
    required this.address,
    required this.phone,
    required this.introduction,
    required this.specialty,
    required this.avatar,
    required this.lat,
    required this.lng,
    this.servicesImage,
    required this.isSuper,
    required this.status,
    required this.serviceId,
    // required this.insurance, // issue empty is String, but have data is List
    required this.tagLine,
    required this.showGoodAt,
    required this.goodAt,
    required this.defaultGoodAt,
    required this.clinicId,
    required this.serviceType,
    required this.serviceList,
    required this.schedule,
    required this.aptInterval,
    required this.extraAvatar,
    required this.svAvailable,
    required this.profileType,
  });

  factory DsmesClinicModel.fromJson(Map<String, dynamic> json) {
    return DsmesClinicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      language: List<String>.from(json['language'] ?? []),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      introduction: json['introduction'] ?? '',
      specialty: (json['specialty'] as List?)
              ?.map((e) => SpecialtyDetail.fromJson(e))
              .toList() ??
          [],
      avatar: json['avatar'] ?? '',
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      servicesImage: json['services_image'],
      isSuper: json['is_super'] ?? '',
      status: json['status'] ?? '',
      serviceId: json['service_id'] ?? 0,
      // insurance: json['insurance'] ?? '',
      tagLine: json['tag_line'] ?? '',
      showGoodAt: Map<String, int>.from(json['show_good_at'] ?? {}),
      goodAt: (json['good_at'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => GoodAt.fromJson(e)).toList(),
            ),
          ) ??
          {},
      defaultGoodAt: (json['default_good_at'] as List?)
              ?.map((e) => GoodAt.fromJson(e))
              .toList() ??
          [],
      clinicId: json['clinic_id'] ?? 0,
      serviceType: json['service_type'] ?? [],
      serviceList: ServiceList.fromJson(json['service_list'] ?? {}),
      schedule: _parseSchedule(json['schedule'] ?? {}),
      aptInterval: json['apt_interval'] ?? '',
      extraAvatar: (json['extra_avatar'] as List?)
              ?.map((e) => ExtraAvatar.fromJson(e))
              .toList() ??
          [],
      svAvailable: (json['sv_available'] as List?)
              ?.map((e) => ServiceAvailable.fromJson(e))
              .toList() ??
          [],
      profileType: json['profile_type'] ?? '',
    );
  }

  static Map<String, Map<String, int>> _parseSchedule(
      Map<String, dynamic> json) {
    Map<String, Map<String, int>> result = {};
    json.forEach((key, value) {
      if (value is Map) {
        result[key] = Map<String, int>.from(value);
      } else if (value is List) {
        result[key] = {};
      }
    });
    return result;
  }

  List<GoodAt> getGoodAtByLocale(String locale) {
    if (goodAt.containsKey(locale)) {
      return goodAt[locale] ?? [];
    }
    return defaultGoodAt;
  }

  List<BookingSchedule> getBookingSchedules() {
    List<BookingSchedule> bookingSchedules = [];

    schedule.forEach((date, slots) {
      slots.forEach((time, status) {
        final startDateTime = DateFormat('yyyy-MM-dd HH:mm')
            .parse("$date ${time.split('.')[0]}:${time.split('.')[1]}0")
            .toString()
            .substring(0, 16);
        final endDateTime = DateFormat('yyyy-MM-dd HH:mm')
            .parse(startDateTime)
            .add(Duration(minutes: int.parse(aptInterval)))
            .toString()
            .substring(0, 16);

        bookingSchedules.add(
          BookingSchedule(
            startTime: startDateTime,
            endTime: endDateTime,
            isAvailable: status == 1,
          ),
        );
      });
    });

    bookingSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return bookingSchedules;
  }
}

class BookingSchedule {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  BookingSchedule({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });
}

class SpecialtyDetail {
  final int id;
  final int clinicId;
  final int specialtyId;
  final String isPrimary;
  final SpecialtyInfo info;

  SpecialtyDetail({
    required this.id,
    required this.clinicId,
    required this.specialtyId,
    required this.isPrimary,
    required this.info,
  });

  factory SpecialtyDetail.fromJson(Map<String, dynamic> json) {
    return SpecialtyDetail(
      id: json['id'] ?? 0,
      clinicId: json['clinic_id'] ?? 0,
      specialtyId: json['specialty_id'] ?? 0,
      isPrimary: json['is_primary'] ?? '',
      info: SpecialtyInfo.fromJson(json['info'] ?? {}),
    );
  }
}

class SpecialtyInfo {
  final String name;
  final int id;
  final String image;

  SpecialtyInfo({
    required this.name,
    required this.id,
    required this.image,
  });

  factory SpecialtyInfo.fromJson(Map<String, dynamic> json) {
    return SpecialtyInfo(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class GoodAt {
  final int id;
  final String name;

  GoodAt({
    required this.id,
    required this.name,
  });

  factory GoodAt.fromJson(Map<String, dynamic> json) {
    return GoodAt(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ServiceList {
  final String name;
  final int id;
  final List<ServiceCategory> categories;

  ServiceList({
    required this.name,
    required this.id,
    required this.categories,
  });

  factory ServiceList.fromJson(Map<String, dynamic> json) {
    return ServiceList(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      categories: (json['categories'] as List?)
              ?.map((e) => ServiceCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ServiceCategory {
  final String name;
  final int id;
  final String type;
  final List<ServiceData> data;
  final String slug;

  ServiceCategory({
    required this.name,
    required this.id,
    required this.type,
    required this.data,
    required this.slug,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => ServiceData.fromJson(e))
              .toList() ??
          [],
      slug: json['slug'] ?? '',
    );
  }
}

class ServiceData {
  final String name;
  final int id;
  final String priceType;
  final int fromPrice;
  final int toPrice;
  final String unit;
  final String currencyUnit;
  final String description;
  final int isPayment;
  final String value;

  ServiceData({
    required this.name,
    required this.id,
    required this.priceType,
    required this.fromPrice,
    required this.toPrice,
    required this.unit,
    required this.currencyUnit,
    required this.description,
    required this.isPayment,
    required this.value,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      priceType: json['price_type'] ?? '',
      fromPrice: json['from_price'] ?? 0,
      toPrice: json['to_price'] ?? 0,
      unit: json['unit'] ?? '',
      currencyUnit: json['currency_unit'] ?? '',
      description: json['description'] ?? '',
      isPayment: json['is_payment'] ?? 0,
      value: json['value'] ?? '',
    );
  }
}

// Add this class to handle extra avatar data
class ExtraAvatar {
  final int id;
  final String path;
  final String thumbPath;

  ExtraAvatar({
    required this.id,
    required this.path,
    required this.thumbPath,
  });

  factory ExtraAvatar.fromJson(Map<String, dynamic> json) {
    return ExtraAvatar(
      id: json['id'] ?? 0,
      path: json['path'] ?? '',
      thumbPath: json['thumb_path'] ?? '',
    );
  }
}

class ServiceAvailable {
  final String key;
  final String name;

  ServiceAvailable({
    required this.key,
    required this.name,
  });

  factory ServiceAvailable.fromJson(Map<String, dynamic> json) {
    return ServiceAvailable(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
