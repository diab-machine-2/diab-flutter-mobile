class NotifySubscriptionRequest {
  String servicePackage;
  String programName;

  NotifySubscriptionRequest({
    required this.servicePackage,
    required this.programName,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ServicePackage'] = servicePackage;
    data['ProgramName'] = programName;
    return data;
  }
}
