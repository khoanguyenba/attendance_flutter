class CreateWorkTimeCommand {
  final String name;
  final String validCheckInTime;
  final String validCheckOutTime;
  final bool isActive;

  CreateWorkTimeCommand({
    required this.name,
    required this.validCheckInTime,
    required this.validCheckOutTime,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'validCheckInTime': validCheckInTime,
      'validCheckOutTime': validCheckOutTime,
      'isActive': isActive,
    };
  }
}
