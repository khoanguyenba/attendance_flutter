import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';

abstract class DepartmentRemoteDataSource {
  Future<String> createDepartment(Map<String, dynamic> data);
  Future<List<DepartmentModel>> getDepartments();
  Future<void> updateDepartment(String id, Map<String, dynamic> data);
  Future<void> deleteDepartment(String id);
}

class DepartmentRemoteDataSourceImpl implements DepartmentRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'departments';

  @override
  Future<String> createDepartment(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create department: $e');
    }
  }

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DepartmentModel.fromListJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get departments: $e');
    }
  }

  @override
  Future<void> updateDepartment(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update department: $e');
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }
}
