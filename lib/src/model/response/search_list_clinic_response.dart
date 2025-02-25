import 'package:medical/src/widget/booking_clinic/model/booking_clinic_provider_model.dart';

class SearchListClinicResponse {
  final int code;
  final BookingClinicData data;
  final Attr attr;

  SearchListClinicResponse({
    required this.code,
    required this.data,
    required this.attr,
  });

  factory SearchListClinicResponse.fromJson(Map<String, dynamic> json) {
    return SearchListClinicResponse(
      code: json['code'],
      data: BookingClinicData.fromJson(json['data']),
      attr: Attr.fromJson(json['attr']),
    );
  }
}

class BookingClinicData {
  final List<BookingClinicProvider> providers;

  BookingClinicData({required this.providers});

  factory BookingClinicData.fromJson(Map<String, dynamic> json) {
    return BookingClinicData(
      providers: (json['providers'] as List)
          .map((e) => BookingClinicProvider.fromJson(e))
          .toList(),
    );
  }
}

class Attr {
  final int total;
  final int? totalPage;
  final int? currentPage;

  Attr({
    required this.total,
     this.totalPage,
     this.currentPage,
  });

  factory Attr.fromJson(Map<String, dynamic> json) {
    return Attr(
      total: json['total'],
      totalPage: json['total_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
    );
  }
}
