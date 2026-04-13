import '../entities/item_list.dart';
import '../repositories/lists_repository.dart';

class CreateListUsecase {
  final ListsRepository _repository;
  const CreateListUsecase(this._repository);

  Future<ItemList> call(String name) => _repository.createList(name);
}
