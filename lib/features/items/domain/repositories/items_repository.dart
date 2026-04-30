import 'package:circulari/core/models/paginated_result.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item.dart';

abstract interface class ItemsRepository {
  Future<List<Category>> getCategories();
  Future<List<Item>> getItems(String listId);
  Future<PaginatedResult<Item>> searchItems({
    String? search,
    String? cursor,
    int? limit,
  });
  Future<Item> createItem({
    required String listId,
    required String name,
    String? description,
    int quantity,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
    String? imagePath,
  });
  Future<Item> updateItem(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
  });
  Future<void> deleteItem(String id);
  Future<Item> uploadItemImage(String itemId, String imagePath);
  Future<AiAnalysisResult> analyzeImage(String imagePath);
}
