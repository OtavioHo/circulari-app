import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class DeleteItemUsecase {
  final ItemsRepository _repository;
  const DeleteItemUsecase(this._repository);

  Future<void> call(String id) => _repository.deleteItem(id);
}
