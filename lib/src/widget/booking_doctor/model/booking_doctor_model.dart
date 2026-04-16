import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';

class BookingDoctorModel {
  final int id;
  final String name;
  final List<String> language;
  final String address;
  final String phone;
  final String introduction;
  final List<DoctorSpecialtyDetail> specialty;
  final String avatar;
  final String lat;
  final String lng;
  final String? servicesImage;
  final String isSuper;
  final String status;
  final int serviceId;
  // final String insurance;
  // final String tagLine;
  final Map<String, int> showGoodAt;
  final Map<String, List<GoodAt>> goodAt;
  final List<GoodAt> defaultGoodAt;
  final int clinicId;
  final List<dynamic> serviceType;
  final ServiceList serviceList;
  final Map<String, Map<String, int>> schedule;
  final String aptInterval;
  final List<ExtraAvatar> extraAvatar;
  final List<ServiceAvailable>
      svAvailable; // 'at_clinic', 'telemedicine', 'at_home'
  final String profileType; // 'booking' or 'premium'
  final Map<String, String>? graduateName;
  final List<Education>? education;
  final List<OwnerClinic>? ownerClinics;
  final List<OwnerClinic>? ownerClinic;
  final List<OwnerClinic>? staffClinic;
  final String? displayName; // doctor name
  final String? experience;
  final int? totalReview;

  BookingDoctorModel({
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
    // required this.tagLine,
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
    this.graduateName,
    this.education,
    this.ownerClinics,
    this.ownerClinic,
    this.staffClinic,
    this.displayName,
    this.experience,
    this.totalReview,
  });

  factory BookingDoctorModel.fromJson(Map<String, dynamic> json) {
    return BookingDoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      language: List<String>.from(json['language'] ?? []),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      introduction: json['introduction'] ?? '',
      specialty: (json['specialty'] as List?)
              ?.map((e) => DoctorSpecialtyDetail.fromJson(e))
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
      // tagLine: json['tag_line'] ?? '',
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
      serviceList: json['service_list'] is List
          ? (json['service_list'] as List).isNotEmpty
              ? ServiceList.fromJson(json['service_list'][0])
              : ServiceList.fromJson({})
          : ServiceList.fromJson(json['service_list'] ?? {}),

      schedule: _parseSchedule(json['schedule']),
      aptInterval: json['apt_interval'] ??
          _calculateIntervalFromSchedule(_parseSchedule(json['schedule'])),
      extraAvatar: (json['extra_avatar'] as List?)
              ?.map((e) => ExtraAvatar.fromJson(e))
              .toList() ??
          [],
      svAvailable: (json['sv_available'] as List?)
              ?.map((e) => ServiceAvailable.fromJson(e))
              .toList() ??
          [],
      profileType: json['profile_type'] ?? '',
      graduateName: _parseGraduateName(json['graduate_name']),
      education: (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      ownerClinics: (json['owner_clinics'] as List?)
              ?.map((e) => OwnerClinic.fromJson(e))
              .toList() ??
          [],
      ownerClinic: (json['owner_clinic'] as List?)
              ?.map((e) => OwnerClinic.fromJson(e))
              .toList() ??
          [],
      staffClinic: (json['staff_clinic'] as List?)
              ?.map((e) => OwnerClinic.fromJson(e))
              .toList() ??
          [],
      displayName: json['display_name'] ?? '',
      experience: json['experience'] ?? '',
      totalReview: json['total_review'] ?? 0,
    );
  }

  OwnerClinic? getFirstOwnerClinic() {
    if (ownerClinic != null && ownerClinic!.isNotEmpty) {
      return ownerClinic!.first;
    }

    if (staffClinic != null && staffClinic!.isNotEmpty) {
      return staffClinic!.first;
    }

    return null;
  }

  static Map<String, Map<String, int>> _parseSchedule(dynamic scheduleData) {
    Map<String, Map<String, int>> result = {};

    // Handle case where schedule is a List (empty or otherwise)
    if (scheduleData is List) {
      return result; // Return empty map if schedule is a List
    }

    // Handle case where schedule is null or not a Map
    if (scheduleData == null || scheduleData is! Map) {
      return result; // Return empty map
    }

    // Handle case where schedule is a Map
    final json = scheduleData as Map<String, dynamic>;
    json.forEach((key, value) {
      if (value is Map) {
        result[key] = Map<String, int>.from(value);
      } else if (value is List) {
        result[key] = {};
      }
    });
    return result;
  }

  static String _calculateIntervalFromSchedule(
      Map<String, Map<String, int>> schedule) {
    // Try to find interval from consecutive slots within each date
    List<int> intervals = [];

    schedule.forEach((date, slots) {
      if (slots.length < 2)
        return; // Need at least 2 slots to calculate interval

      // Convert time strings to minutes and sort
      List<MapEntry<String, int>> sortedSlots = slots.entries.toList()
        ..sort((a, b) {
          try {
            final aParts = a.key.split('.');
            final bParts = b.key.split('.');
            final aHour = int.parse(aParts[0]);
            final aMinutes = aParts.length > 1 ? int.parse(aParts[1]) : 0;
            final bHour = int.parse(bParts[0]);
            final bMinutes = bParts.length > 1 ? int.parse(bParts[1]) : 0;

            final aTotal = aHour * 60 + aMinutes;
            final bTotal = bHour * 60 + bMinutes;
            return aTotal.compareTo(bTotal);
          } catch (e) {
            return 0;
          }
        });

      // Calculate intervals between consecutive slots
      for (int i = 0; i < sortedSlots.length - 1; i++) {
        try {
          final time1Parts = sortedSlots[i].key.split('.');
          final time2Parts = sortedSlots[i + 1].key.split('.');

          final hour1 = int.parse(time1Parts[0]);
          final minutes1 = time1Parts.length > 1 ? int.parse(time1Parts[1]) : 0;
          final hour2 = int.parse(time2Parts[0]);
          final minutes2 = time2Parts.length > 1 ? int.parse(time2Parts[1]) : 0;

          final total1 = hour1 * 60 + minutes1;
          final total2 = hour2 * 60 + minutes2;

          final interval = total2 - total1;
          if (interval > 0) {
            intervals.add(interval);
          }
        } catch (e) {
          // Skip invalid time formats
          continue;
        }
      }
    });

    // Return the most common interval, or the first one found, or default
    if (intervals.isNotEmpty) {
      // Find the minimum interval (most likely the appointment interval)
      intervals.sort();
      return intervals.first.toString();
    }

    // Default fallback if we can't calculate
    return '30';
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
        final timeParts = time.split('.');
        final hour = int.parse(timeParts[0]);
        // For the minutes part, we need to handle correctly - no need to add "0"
        final minutes = timeParts.length > 1 ? timeParts[1] : "0";

        final startDateTime =
            "$date ${hour.toString().padLeft(2, '0')}:${minutes.padLeft(2, '0')}";

        final parsedStartDateTime =
            DateFormat('yyyy-MM-dd HH:mm').parse(startDateTime);
        final endDateTime = parsedStartDateTime
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

  bool hasServiceAvailable(DsmesAppointmentMode mode) {
    return svAvailable.any((service) => service.key == mode.toString());
  }
}

class Education {
  final String name;
  final String value;

  Education({
    required this.name,
    required this.value,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class OwnerClinic {
  final int id;
  final String name;
  final String address;

  OwnerClinic({
    required this.id,
    required this.name,
    required this.address,
  });

  factory OwnerClinic.fromJson(Map<String, dynamic> json) {
    return OwnerClinic(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class DoctorSpecialtyDetail {
  final String name;
  final SpecialtyPivot pivot;

  DoctorSpecialtyDetail({
    required this.name,
    required this.pivot,
  });

  factory DoctorSpecialtyDetail.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialtyDetail(
      name: json['name'] ?? '',
      pivot: SpecialtyPivot.fromJson(json['pivot'] ?? {}),
    );
  }
}

class SpecialtyPivot {
  final int doctorId;
  final int specialtyId;

  SpecialtyPivot({
    required this.doctorId,
    required this.specialtyId,
  });

  factory SpecialtyPivot.fromJson(Map<String, dynamic> json) {
    return SpecialtyPivot(
        doctorId: json['doctor_id'] ?? 0,
        specialtyId: json['specialty_id'] ?? 0);
  }
}

Map<String, String>? _parseGraduateName(dynamic graduateName) {
  if (graduateName == null) return null;

  if (graduateName is String) {
    // If it's a string, create a map with both vi and en as the same value
    return {
      'name_vi': graduateName,
      'name_en': graduateName,
    };
  } else if (graduateName is Map) {
    // If it's already a map, convert it
    return Map<String, String>.from(graduateName);
  }

  return null;
}
