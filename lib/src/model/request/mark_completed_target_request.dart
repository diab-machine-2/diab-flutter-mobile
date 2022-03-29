class MarkCompletedTargetRequest {
/*
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "type": 0,
  "executeTimes": 0
} 
*/

  int? type;
  int? executeTimes;
  int? appointmentDate;

  MarkCompletedTargetRequest({
    this.type,
    this.executeTimes,
    this.appointmentDate,
  });
  MarkCompletedTargetRequest.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toInt();
    executeTimes = json['executeTimes']?.toInt();
    appointmentDate = json['appointmentDate']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (type != null) data['type'] = type;
    if (executeTimes != null) data['executeTimes'] = executeTimes;
    if(appointmentDate != null) data['appointmentDate'] = appointmentDate;
    return data;
  }
}
