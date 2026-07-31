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
    final rawData = json['data'];
    final rawAttr = json['attr'];
    return SearchListClinicResponse(
      code: json['code'] ?? 0,
      data: (rawData is Map<String, dynamic>)
          ? BookingClinicData.fromJson(rawData)
          : BookingClinicData(providers: []),
      attr: (rawAttr is Map<String, dynamic>)
          ? Attr.fromJson(rawAttr)
          : Attr(total: 0),
    );
  }
}

class BookingClinicData {
  final List<BookingClinicProvider> providers;
  final List<ClinicCluster> clusters;

  BookingClinicData({required this.providers, this.clusters = const []});

  factory BookingClinicData.fromJson(Map<String, dynamic> json) {
    final rawProviders = json['providers'];
    final rawClusters = json['clusters'];
    return BookingClinicData(
      providers: (rawProviders is List)
          ? rawProviders
              .map((e) => BookingClinicProvider.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      clusters: (rawClusters is List)
          ? rawClusters
              .map((e) => ClinicCluster.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class ClinicCluster {
  final int clinicId;
  final String name;
  final List<BranchItem> branches;

  ClinicCluster({required this.clinicId, required this.name, required this.branches});

  factory ClinicCluster.fromJson(Map<String, dynamic> json) => ClinicCluster(
    clinicId: json['clinic_id'] ?? 0,
    name: json['name'] ?? '',
    branches: (json['branches'] as List?)
        ?.map((e) => BranchItem.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class BranchItem {
  final int id;
  final int clinicId;
  final String name;
  final String address;

  BranchItem({required this.id, required this.clinicId, required this.name, required this.address});

  factory BranchItem.fromJson(Map<String, dynamic> json) => BranchItem(
    id: json['id'] ?? 0,
    clinicId: json['clinic_id'] ?? 0,
    name: json['name'] ?? '',
    address: json['address'] ?? '',
  );
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
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
    );
  }
}
