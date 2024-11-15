class BranchioGenerateZoomResponse {
  final String? topic;
  final String id;
  final String password;
  final String email;
  final int startDate;
  final String branchioLink;
  final String? zoomHostLink;
  final String? zoomClientLink;

  BranchioGenerateZoomResponse({
    this.topic,
    required this.id,
    required this.password,
    required this.email,
    required this.startDate,
    required this.branchioLink,
    this.zoomHostLink,
    this.zoomClientLink,
  });

  factory BranchioGenerateZoomResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return BranchioGenerateZoomResponse(
      topic: json['topic'],
      id: json['id'] ?? '00000000-0000-0000-0000-000000000000',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      startDate: json['startDate'] ?? 0,
      branchioLink: json['branchioLink'] ?? '',
      zoomHostLink: json['zoomHostLink'],
      zoomClientLink: json['zoomClientLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'id': id,
      'password': password,
      'email': email,
      'startDate': startDate,
      'branchioLink': branchioLink,
      'zoomHostLink': zoomHostLink,
      'zoomClientLink': zoomClientLink,
    };
  }
}
