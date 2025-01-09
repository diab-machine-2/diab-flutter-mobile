class GlucoseFaq {
  final String title;
  final String linkTitle;
  final String url;

  GlucoseFaq({
    required this.title,
    required this.linkTitle,
    required this.url,
  });

  factory GlucoseFaq.fromJson(Map<String, dynamic> json) {
    return GlucoseFaq(
      title: json['title']!,
      linkTitle: json['linkTitle']!,
      url: json['url']!,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['linkTitle'] = linkTitle;
    map['url'] = url;
    return map;
  }
}
