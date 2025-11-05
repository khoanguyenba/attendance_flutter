class GetPageAttendanceHistoryQuery {
  final int pageIndex;
  final int pageSize;
  final String? employeeId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetPageAttendanceHistoryQuery({
    this.pageIndex = 1,
    this.pageSize = 20,
    this.employeeId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> m = {
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
    if (employeeId != null) m['employeeId'] = employeeId;
    if (startDate != null) m['startDate'] = startDate!.toIso8601String();
    if (endDate != null) m['endDate'] = endDate!.toIso8601String();
    return m;
  }
}
