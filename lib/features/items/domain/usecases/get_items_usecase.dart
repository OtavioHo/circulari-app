import 'package:circulari/features/items/domain/entities/items_page.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class GetItemsUsecase {
  final ItemsRepository _repository;
  const GetItemsUsecase(this._repository);

  Future<ItemsPage> call(
    String listId, {
    String? cursor,
    int? limit,
  }) =>
      _repository.getItems(listId, cursor: cursor, limit: limit);
}
