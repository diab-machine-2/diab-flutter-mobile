class CompleteUpdateProfileRequest {
  String? id;

  CompleteUpdateProfileRequest({
    this.id,
  });
  CompleteUpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}
