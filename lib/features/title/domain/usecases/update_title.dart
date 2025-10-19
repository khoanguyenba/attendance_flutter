import '../repositories/title_repository.dart';

class UpdateTitle {
  final TitleRepository repository;

  UpdateTitle(this.repository);

  Future<void> call({
    required String id,
    required String name,
    String? description,
  }) async {
    return await repository.updateTitle(
      id: id,
      name: name,
      description: description,
    );
  }
}
