import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class GetItemsUsecase {
  final ItemsRepository _repository;
  const GetItemsUsecase(this._repository);

  Future<List<Item>> call(String listId) => _repository.getItems(listId);
}
