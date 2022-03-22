class MarkShareRequest {

  String? patientId;
  bool? isShare;

  MarkShareRequest({
    this.patientId,
    this.isShare,
  });
  
  MarkShareRequest.fromJson(Map<String, dynamic> json) {
    patientId = json['patientId']?.toString();
    isShare = json['isShare'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['patientId'] = patientId;
    data['isShare'] = isShare;
    return data;
  }
}
