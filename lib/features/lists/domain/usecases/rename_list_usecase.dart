import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class RenameListUsecase {
  final ListsRepository _repository;
  const RenameListUsecase(this._repository);

  Future<void> call(String id, String name) => _repository.renameList(id, name);
}
