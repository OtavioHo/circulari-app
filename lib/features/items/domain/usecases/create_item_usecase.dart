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
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
    String? imagePath,
  }) =>
      _repository.createItem(
        listId: listId,
        name: name,
        description: description,
        quantity: quantity,
        categoryId: categoryId,
        locationId: locationId,
        userDefinedValue: userDefinedValue,
        imagePath: imagePath,
      );
}
