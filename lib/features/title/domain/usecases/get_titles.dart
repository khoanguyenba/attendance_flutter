import '../entities/title.dart';
import '../repositories/title_repository.dart';

class GetTitles {
  final TitleRepository repository;

  GetTitles(this.repository);

  Future<List<Title>> call() async {
    return await repository.getTitles();
  }
}
