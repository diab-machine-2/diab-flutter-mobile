class ClinicResultScanResponse {
  final ClinicResultScanData? data;

  const ClinicResultScanResponse({this.data});

  factory ClinicResultScanResponse.fromJson(Map<String, dynamic> json) =>
      ClinicResultScanResponse(
        data: json['data'] != null
            ? ClinicResultScanData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class ClinicResultScanData {
  final String? diagnose;
  final List<String> services;

  const ClinicResultScanData({
    this.diagnose,
    required this.services,
  });

  factory ClinicResultScanData.fromJson(Map<String, dynamic> json) =>
      ClinicResultScanData(
        diagnose: json['diagnose'] as String?,
        services: (json['services'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
