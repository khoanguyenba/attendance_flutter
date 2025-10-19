import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceResponseModel> checkIn(Map<String, dynamic> data);
  Future<AttendanceResponseModel> checkOut(Map<String, dynamic> data);
  Future<List<AttendanceModel>> getAttendanceHistory(Map<String, dynamic> params);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'attendances';

  @override
  Future<AttendanceResponseModel> checkIn(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'type': 'check_in',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      return AttendanceResponseModel(
        id: docRef.id,
        message: 'Check in successful',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  @override
  Future<AttendanceResponseModel> checkOut(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'type': 'check_out',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      return AttendanceResponseModel(
        id: docRef.id,
        message: 'Check out successful',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to check out: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(Map<String, dynamic> params) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Apply filters based on params
      if (params.containsKey('employeeId') && params['employeeId'] != null) {
        query = query.where('employeeId', isEqualTo: params['employeeId']);
      }
      if (params.containsKey('date') && params['date'] != null) {
        final date = DateTime.parse(params['date'] as String);
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                    .where('timestamp', isLessThan: endOfDay);
      }
      
      final querySnapshot = await query.orderBy('timestamp', descending: true).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AttendanceModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get attendance history: $e');
    }
  }
}
