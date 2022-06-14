class HasSharedProfileRequest {
/*
{
  "referalCode": "21iG90"
} 
*/

  String? referalCode;

  HasSharedProfileRequest({
    this.referalCode,
  });
  HasSharedProfileRequest.fromJson(Map<String, dynamic> json) {
    referalCode = json['referalCode']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['referalCode'] = referalCode;
    return data;
  }
}
