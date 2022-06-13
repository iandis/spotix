Map<String, dynamic>? castFromNativeMap(Map<dynamic, dynamic> map, String key) {
  if (map[key] is! Map<dynamic, dynamic>) return null;
  return Map<String, dynamic>.from(map[key] as Map<dynamic, dynamic>);
}
