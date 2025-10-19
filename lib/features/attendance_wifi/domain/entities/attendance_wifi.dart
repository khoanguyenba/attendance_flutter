class AttendanceWiFi {
  final String id;
  final String location;
  final String ssid;
  final String bssid;
  final String? description;
  final DateTime createdAt;

  const AttendanceWiFi({
    required this.id,
    required this.location,
    required this.ssid,
    required this.bssid,
    this.description,
    required this.createdAt,
  });

  AttendanceWiFi copyWith({
    String? id,
    String? location,
    String? ssid,
    String? bssid,
    String? description,
    DateTime? createdAt,
  }) {
    return AttendanceWiFi(
      id: id ?? this.id,
      location: location ?? this.location,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
