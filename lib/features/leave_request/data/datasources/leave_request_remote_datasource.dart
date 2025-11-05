import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/leave_request/data/models/approve_leave_request_command.dart';
import 'package:attendance_system/features/leave_request/data/models/leave_request_dto.dart';
import 'package:attendance_system/features/leave_request/data/models/create_leave_request_command.dart';
import 'package:attendance_system/features/leave_request/data/models/delete_leave_request_command.dart';
import 'package:attendance_system/features/leave_request/data/models/get_page_leave_request_query.dart';
import 'package:attendance_system/features/leave_request/data/models/reject_leave_request_command.dart';

abstract class LeaveRequestRemoteDataSource {
  Future<LeaveRequestDto> createLeaveRequest(CreateLeaveRequestCommand command);
  // Update is not supported by the current API (endpoints only show create/get/page/delete).
  Future<void> deleteLeaveRequest(DeleteLeaveRequestCommand command);
  Future<LeaveRequestDto?> getLeaveRequestById(String id);
  Future<List<LeaveRequestDto>> getPageLeaveRequest(
    GetPageLeaveRequestQuery query,
  );
  Future<void> approveLeaveRequest(ApproveLeaveRequestCommand command);
  Future<void> rejectLeaveRequest(RejectLeaveRequestCommand command);
}

class LeaveRequestRemoteDataSourceImpl extends BaseRemoteDataSource
    implements LeaveRequestRemoteDataSource {
  LeaveRequestRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<LeaveRequestDto> createLeaveRequest(
    CreateLeaveRequestCommand command,
  ) async {
    final response = await dio.post(
      '/api/leave-requests',
      data: command.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return LeaveRequestDto.fromJson(response.data);
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Create leave request failed',
    );
  }

  @override
  Future<void> deleteLeaveRequest(DeleteLeaveRequestCommand command) async {
    final response = await dio.delete('/api/leave-requests/${command.id}');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Delete leave request failed',
      );
    }
  }

  @override
  Future<LeaveRequestDto?> getLeaveRequestById(String id) async {
    final response = await dio.get('/api/leave-requests/$id');
    if (response.statusCode == 200) {
      return LeaveRequestDto.fromJson(response.data);
    }
    if (response.statusCode == 404) return null;
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get leave request failed',
    );
  }

  @override
  Future<List<LeaveRequestDto>> getPageLeaveRequest(
    GetPageLeaveRequestQuery query,
  ) async {
    final response = await dio.get(
      '/api/leave-requests',
      queryParameters: query.toQueryParams(),
    );
    if (response.statusCode == 200) {
      final resp = response.data;
      if (resp is List) {
        return resp
            .map((e) => LeaveRequestDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (resp is Map<String, dynamic>) {
        dynamic items =
            resp['items'] ?? resp['data'] ?? resp['results'] ?? resp['rows'];
        if (items == null && resp.containsKey('data') && resp['data'] is Map) {
          final nested = resp['data'] as Map<String, dynamic>;
          items = nested['items'] ?? nested['data'];
        }
        if (items is List) {
          return items
              .map((e) => LeaveRequestDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [LeaveRequestDto.fromJson(resp)];
      }
      return [LeaveRequestDto.fromJson(Map<String, dynamic>.from(resp))];
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get leave requests failed',
    );
  }

  @override
  Future<void> approveLeaveRequest(ApproveLeaveRequestCommand command) async {
    final response = await dio.post(
      '/api/leave-requests/approve',
      data: command.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Approve leave request failed',
      );
    }
  }

  @override
  Future<void> rejectLeaveRequest(RejectLeaveRequestCommand command) async {
    final response = await dio.post(
      '/api/leave-requests/reject',
      data: command.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Reject leave request failed',
      );
    }
  }
}
