T parseJson<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  return fromJson(json);
}
