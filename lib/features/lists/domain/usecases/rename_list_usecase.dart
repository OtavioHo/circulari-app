import '../entities/item_list.dart';
import '../repositories/lists_repository.dart';

class RenameListUsecase {
  final ListsRepository _repository;
  const RenameListUsecase(this._repository);

  Future<ItemList> call(String id, String name) =>
      _repository.renameList(id, name);
}
