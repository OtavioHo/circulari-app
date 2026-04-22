import '../entities/list_color.dart';
import '../repositories/lists_repository.dart';

class GetListColorsUsecase {
  final ListsRepository _repository;
  const GetListColorsUsecase(this._repository);

  Future<List<ListColor>> call() => _repository.getColors();
}
