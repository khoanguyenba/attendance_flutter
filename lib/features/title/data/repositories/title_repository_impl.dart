import '../../domain/entities/title.dart';
import '../../domain/repositories/title_repository.dart';
import '../datasources/title_remote_datasource.dart';

class TitleRepositoryImpl implements TitleRepository {
  final TitleRemoteDataSource remoteDataSource;

  TitleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createTitle({
    required String name,
    String? description,
  }) async {
    final data = {
      'name': name,
      if (description != null) 'description': description,
    };

    return await remoteDataSource.createTitle(data);
  }

  @override
  Future<List<Title>> getTitles() async {
    return await remoteDataSource.getTitles();
  }

  @override
  Future<void> updateTitle({
    required String id,
    required String name,
    String? description,
  }) async {
    final data = {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };

    await remoteDataSource.updateTitle(id, data);
  }

  @override
  Future<void> deleteTitle(String id) async {
    await remoteDataSource.deleteTitle(id);
  }
}
