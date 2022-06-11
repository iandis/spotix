Map<String, dynamic> castFromNativeMap(Map<dynamic, dynamic> map, String key) {
  return Map<String, dynamic>.from(map[key] as Map<dynamic, dynamic>);
}
