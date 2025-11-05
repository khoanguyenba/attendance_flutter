class AppWorkTime {
  final String id;
  final String name;
  final String validCheckInTime; // format: HH:mm:ss
  final String validCheckOutTime; // format: HH:mm:ss
  final bool isActive;

  AppWorkTime({
    required this.id,
    required this.name,
    required this.validCheckInTime,
    required this.validCheckOutTime,
    required this.isActive,
  });
}
