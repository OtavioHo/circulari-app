import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class DeleteListUsecase {
  final ListsRepository _repository;
  const DeleteListUsecase(this._repository);

  Future<void> call(String id) => _repository.deleteList(id);
}
