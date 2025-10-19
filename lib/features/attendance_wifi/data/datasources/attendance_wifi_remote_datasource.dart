import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_wifi_model.dart';

abstract class AttendanceWiFiRemoteDataSource {
  Future<String> createAttendanceWiFi(Map<String, dynamic> data);
  Future<List<AttendanceWiFiModel>> getAttendanceWiFis();
  Future<AttendanceWiFiModel> getAttendanceWiFiDetail(String id);
  Future<void> updateAttendanceWiFi(String id, Map<String, dynamic> data);
  Future<void> deleteAttendanceWiFi(String id);
}

class AttendanceWiFiRemoteDataSourceImpl implements AttendanceWiFiRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'attendance_wifi';

  @override
  Future<String> createAttendanceWiFi(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create attendance WiFi: $e');
    }
  }

  @override
  Future<List<AttendanceWiFiModel>> getAttendanceWiFis() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AttendanceWiFiModel.fromListJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get attendance WiFi list: $e');
    }
  }

  @override
  Future<AttendanceWiFiModel> getAttendanceWiFiDetail(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return AttendanceWiFiModel.fromJson({
          'id': doc.id,
          ...data,
        });
      } else {
        throw Exception('Attendance WiFi not found');
      }
    } catch (e) {
      throw Exception('Failed to get attendance WiFi detail: $e');
    }
  }

  @override
  Future<void> updateAttendanceWiFi(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update attendance WiFi: $e');
    }
  }

  @override
  Future<void> deleteAttendanceWiFi(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete attendance WiFi: $e');
    }
  }
}
