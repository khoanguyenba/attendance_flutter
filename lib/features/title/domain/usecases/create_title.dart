import '../repositories/title_repository.dart';

class CreateTitle {
  final TitleRepository repository;

  CreateTitle(this.repository);

  Future<String> call({
    required String name,
    String? description,
  }) async {
    return await repository.createTitle(
      name: name,
      description: description,
    );
  }
}
