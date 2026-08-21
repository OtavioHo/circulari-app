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
  Future<void> updateList(
    String id, {
    required String name,
    String? location,
    String? colorId,
    String? iconId,
    String? pictureId,
  });
  Future<void> deleteList(String id);
}
