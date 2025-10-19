import '../entities/title.dart';

abstract class TitleRepository {
  Future<String> createTitle({
    required String name,
    String? description,
  });

  Future<List<Title>> getTitles();

  Future<void> updateTitle({
    required String id,
    required String name,
    String? description,
  });

  Future<void> deleteTitle(String id);
}
