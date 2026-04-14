import '../entities/item.dart';
import '../repositories/items_repository.dart';

class UpdateItemUsecase {
  final ItemsRepository _repository;
  const UpdateItemUsecase(this._repository);

  Future<Item> call(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? locationId,
    double? userDefinedValue,
  }) =>
      _repository.updateItem(
        id,
        name: name,
        description: description,
        quantity: quantity,
        locationId: locationId,
        userDefinedValue: userDefinedValue,
      );
}
