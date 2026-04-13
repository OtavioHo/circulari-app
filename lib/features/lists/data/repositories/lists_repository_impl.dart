import '../../domain/entities/item_list.dart';
import '../../domain/repositories/lists_repository.dart';
import '../sources/lists_remote_source.dart';

class ListsRepositoryImpl implements ListsRepository {
  final ListsRemoteSource _source;
  const ListsRepositoryImpl(this._source);

  @override
  Future<List<ItemList>> getLists() => _source.getLists();

  @override
  Future<ItemList> createList(String name) => _source.createList(name);

  @override
  Future<ItemList> renameList(String id, String name) =>
      _source.renameList(id, name);

  @override
  Future<void> deleteList(String id) => _source.deleteList(id);
}
