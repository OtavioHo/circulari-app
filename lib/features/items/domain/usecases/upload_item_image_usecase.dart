import '../entities/item.dart';
import '../repositories/items_repository.dart';

class UploadItemImageUsecase {
  final ItemsRepository _repository;
  const UploadItemImageUsecase(this._repository);

  Future<Item> call(String itemId, String imagePath) =>
      _repository.uploadItemImage(itemId, imagePath);
}
