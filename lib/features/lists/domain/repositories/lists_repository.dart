import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/domain/entities/list_picture.dart';

abstract interface class ListsRepository {
  Future<List<ItemList>> getLists();
  Future<List<ListColor>> getColors();
  Future<List<ListIcon>> getIcons();
  Future<List<ListPicture>> getPictures();
  Future<String> createList({
    required String name,
    String? location,
    required String colorId,
    required String iconId,
    required String pictureId,
  });
  Future<void> renameList(String id, String name);
  Future<void> deleteList(String id);
}
