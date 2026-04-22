import '../../domain/entities/item_list.dart';
import '../../domain/entities/list_color.dart';
import '../../domain/entities/list_icon.dart';
import '../../domain/entities/list_picture.dart';
import '../../domain/repositories/lists_repository.dart';
import '../sources/lists_remote_source.dart';

class ListsRepositoryImpl implements ListsRepository {
  final ListsRemoteSource _source;
  const ListsRepositoryImpl(this._source);

  @override
  Future<List<ItemList>> getLists() => _source.getLists();

  @override
  Future<List<ListColor>> getColors() => _source.getColors();

  @override
  Future<List<ListIcon>> getIcons() => _source.getIcons();

  @override
  Future<List<ListPicture>> getPictures() => _source.getPictures();

  @override
  Future<void> createList({
    required String name,
    String? location,
    required String colorId,
    required String iconId,
    required String pictureId,
  }) => _source.createList(
        name: name,
        location: location,
        colorId: colorId,
        iconId: iconId,
        pictureId: pictureId,
      );

  @override
  Future<void> renameList(String id, String name) =>
      _source.renameList(id, name);

  @override
  Future<void> deleteList(String id) => _source.deleteList(id);
}
