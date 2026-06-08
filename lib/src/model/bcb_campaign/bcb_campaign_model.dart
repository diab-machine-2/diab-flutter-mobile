class BcbCampaignModel {
  String? id;
  String? name;
  String? partnerName;
  DateTime? startDate;
  int? status; // 1=Draft 2=Active 3=Completed 4=Cancelled

  BcbCampaignModel({
    this.id,
    this.name,
    this.partnerName,
    this.startDate,
    this.status,
  });

  factory BcbCampaignModel.fromJson(Map<String, dynamic> json) {
    return BcbCampaignModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      partnerName: json['partnerName'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partnerName': partnerName,
      'startDate': startDate?.toIso8601String(),
      'status': status,
    };
  }

  static List<BcbCampaignModel> toList(List<dynamic> data) {
    return data.map((e) => BcbCampaignModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
