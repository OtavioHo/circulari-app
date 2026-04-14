import '../entities/item.dart';
import '../repositories/items_repository.dart';

class CreateItemUsecase {
  final ItemsRepository _repository;
  const CreateItemUsecase(this._repository);

  Future<Item> call({
    required String listId,
    required String name,
    String? description,
    int quantity = 1,
    String? locationId,
    double? userDefinedValue,
  }) =>
      _repository.createItem(
        listId: listId,
        name: name,
        description: description,
        quantity: quantity,
        locationId: locationId,
        userDefinedValue: userDefinedValue,
      );
}
