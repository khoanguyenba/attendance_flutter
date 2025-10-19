import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<String> createEmployee(Map<String, dynamic> data);
  Future<List<EmployeeModel>> getEmployees(Map<String, dynamic> params);
  Future<EmployeeModel> getEmployeeDetail(String id);
  Future<void> updateEmployee(String id, Map<String, dynamic> data);
  Future<List<EmployeeBasicInfoModel>> getEmployeeBasicInfo();
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  @override
  Future<String> createEmployee(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  @override
  Future<List<EmployeeModel>> getEmployees(Map<String, dynamic> params) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Apply filters based on params
      if (params.containsKey('departmentId') && params['departmentId'] != null) {
        query = query.where('departmentId', isEqualTo: params['departmentId']);
      }
      if (params.containsKey('titleId') && params['titleId'] != null) {
        query = query.where('titleId', isEqualTo: params['titleId']);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EmployeeModel.fromListJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get employees: $e');
    }
  }

  @override
  Future<EmployeeModel> getEmployeeDetail(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return EmployeeModel.fromJson({
          'id': doc.id,
          ...data,
        });
      } else {
        throw Exception('Employee not found');
      }
    } catch (e) {
      throw Exception('Failed to get employee detail: $e');
    }
  }

  @override
  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  @override
  Future<List<EmployeeBasicInfoModel>> getEmployeeBasicInfo() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EmployeeBasicInfoModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get employee basic info: $e');
    }
  }
}
