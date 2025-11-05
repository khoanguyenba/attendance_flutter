import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class GetPageLeaveRequestQuery {
  final int pageIndex;
  final int pageSize;
  final String? employeeId;
  final LeaveStatus? status;

  GetPageLeaveRequestQuery({
    this.pageIndex = 1,
    this.pageSize = 20,
    this.employeeId,
    this.status,
  });

  Map<String, dynamic> toQueryParams() {
    final m = <String, dynamic>{'pageIndex': pageIndex, 'pageSize': pageSize};
    if (employeeId != null) m['employeeId'] = employeeId;
    if (status != null) m['status'] = status!.name;
    return m;
  }
}
