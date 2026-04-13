import '../entities/item_list.dart';
import '../repositories/lists_repository.dart';

class GetListsUsecase {
  final ListsRepository _repository;
  const GetListsUsecase(this._repository);

  Future<List<ItemList>> call() => _repository.getLists();
}
