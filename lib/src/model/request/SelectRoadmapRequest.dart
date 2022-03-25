class SelectRoadmapRequest {

  String? roadmapId;
  int? startDate;

  SelectRoadmapRequest({
    this.roadmapId,
    this.startDate,
  });
  SelectRoadmapRequest.fromJson(Map<String, dynamic> json) {
    roadmapId = json['roadmapId']?.toString();
    startDate = json['startDate'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roadmapId'] = roadmapId;
    data['startDate'] = startDate;
    return data;
  }
}
