import 'package:circulari/core/models/paginated_result.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/entities/items_page.dart';

abstract interface class ItemsRepository {
  Future<List<Category>> getCategories();
  Future<ItemsPage> getItems(
    String listId, {
    String? cursor,
    int? limit,
  });
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
    String? aiAnalysisId,
  });
  Future<Item> updateItem(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
    String? aiAnalysisId,
  });
  Future<void> deleteItem(String id);
  Future<Item> uploadItemImage(String itemId, String imagePath);
  Future<AiAnalysisResult> analyzeImage(
    String imagePath, {
    String? hint,
    String? parentAnalysisId,
  });
  Future<AiAnalysisResult> analyzeItem(
    String itemId, {
    String? hint,
    String? parentAnalysisId,
  });
}
