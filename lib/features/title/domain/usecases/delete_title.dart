import '../repositories/title_repository.dart';

class DeleteTitle {
  final TitleRepository repository;

  DeleteTitle(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteTitle(id);
  }
}
