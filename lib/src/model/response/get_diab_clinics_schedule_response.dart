import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';

class GetDiabClinicsScheduleResponse {
  final int code;
  final Map<String, ClinicScheduleData> data;

  GetDiabClinicsScheduleResponse({
    required this.code,
    required this.data,
  });

  factory GetDiabClinicsScheduleResponse.fromJson(Map<String, dynamic> json) {
    Map<String, ClinicScheduleData> schedules = {};
    json['data'].forEach((key, value) {
      schedules[key] = ClinicScheduleData(
        schedule: _parseSchedule(
            Map<String, dynamic>.from(value)..remove('apt_interval')),
        aptInterval: value['apt_interval'],
      );
    });

    return GetDiabClinicsScheduleResponse(
      code: json['code'],
      data: schedules,
    );
  }

  List<BookingSchedule> getMergedSchedules() {
    List<BookingSchedule> mergedSchedules = [];

    data.forEach((clinicId, clinicData) {
      mergedSchedules.addAll(clinicData.getBookingSchedules());
    });

    // Sort all schedules by start time
    mergedSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Remove duplicates if any
    final uniqueSchedules = mergedSchedules.toSet().toList();

    return uniqueSchedules;
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
}

class ClinicScheduleData {
  final Map<String, Map<String, int>> schedule;
  final String aptInterval;

  ClinicScheduleData({
    required this.schedule,
    required this.aptInterval,
  });

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
