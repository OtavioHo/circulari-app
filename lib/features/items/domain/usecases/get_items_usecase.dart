import '../entities/item.dart';
import '../repositories/items_repository.dart';

class GetItemsUsecase {
  final ItemsRepository _repository;
  const GetItemsUsecase(this._repository);

  Future<List<Item>> call(String listId) => _repository.getItems(listId);
}
