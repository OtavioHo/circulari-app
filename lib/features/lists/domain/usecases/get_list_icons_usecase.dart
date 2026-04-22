import '../entities/list_icon.dart';
import '../repositories/lists_repository.dart';

class GetListIconsUsecase {
  final ListsRepository _repository;
  const GetListIconsUsecase(this._repository);

  Future<List<ListIcon>> call() => _repository.getIcons();
}
