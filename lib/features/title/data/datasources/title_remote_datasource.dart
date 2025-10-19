import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/title_model.dart';

abstract class TitleRemoteDataSource {
  Future<String> createTitle(Map<String, dynamic> data);
  Future<List<TitleModel>> getTitles();
  Future<void> updateTitle(String id, Map<String, dynamic> data);
  Future<void> deleteTitle(String id);
}

class TitleRemoteDataSourceImpl implements TitleRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'titles';

  @override
  Future<String> createTitle(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create title: $e');
    }
  }

  @override
  Future<List<TitleModel>> getTitles() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return TitleModel.fromListJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get titles: $e');
    }
  }

  @override
  Future<void> updateTitle(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update title: $e');
    }
  }

  @override
  Future<void> deleteTitle(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete title: $e');
    }
  }
}
