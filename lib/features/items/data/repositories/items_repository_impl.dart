import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/ai_analysis_result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/items_repository.dart';
import '../sources/items_remote_source.dart';

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsRemoteSource _source;
  const ItemsRepositoryImpl(this._source);

  @override
  Future<List<Category>> getCategories() => _source.getCategories();

  @override
  Future<List<Item>> getItems(String listId) => _source.getItems(listId);

  @override
  Future<PaginatedResult<Item>> searchItems({
    String? search,
    String? cursor,
    int? limit,
  }) =>
      _source.searchItems(search: search, cursor: cursor, limit: limit);

  @override
  Future<Item> createItem({
    required String listId,
    required String name,
    String? description,
    int quantity = 1,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
    String? imagePath,
  }) =>
      _source.createItem(
        listId: listId,
        name: name,
        description: description,
        quantity: quantity,
        categoryId: categoryId,
        locationId: locationId,
        userDefinedValue: userDefinedValue,
        imagePath: imagePath,
      );

  @override
  Future<Item> updateItem(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
  }) =>
      _source.updateItem(
        id,
        name: name,
        description: description,
        quantity: quantity,
        categoryId: categoryId,
        locationId: locationId,
        userDefinedValue: userDefinedValue,
      );

  @override
  Future<void> deleteItem(String id) => _source.deleteItem(id);

  @override
  Future<Item> uploadItemImage(String itemId, String imagePath) =>
      _source.uploadItemImage(itemId, imagePath);

  @override
  Future<AiAnalysisResult> analyzeImage(String imagePath) =>
      _source.analyzeImage(imagePath);
}
