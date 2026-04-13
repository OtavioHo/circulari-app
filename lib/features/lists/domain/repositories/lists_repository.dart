import '../entities/item_list.dart';

abstract interface class ListsRepository {
  Future<List<ItemList>> getLists();
  Future<ItemList> createList(String name);
  Future<ItemList> renameList(String id, String name);
  Future<void> deleteList(String id);
}
