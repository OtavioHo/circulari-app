import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class ShareItemUsecase {
  final ItemsRepository _repository;
  const ShareItemUsecase(this._repository);

  Future<String> call(String id) => _repository.shareItem(id);
}
