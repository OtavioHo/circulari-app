import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class GetListsUsecase {
  final ListsRepository _repository;
  const GetListsUsecase(this._repository);

  Future<List<ItemList>> call() => _repository.getLists();
}
