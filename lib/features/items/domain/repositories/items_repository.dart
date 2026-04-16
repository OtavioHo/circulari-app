import '../entities/ai_analysis_result.dart';
import '../entities/category.dart';
import '../entities/item.dart';

abstract interface class ItemsRepository {
  Future<List<Category>> getCategories();
  Future<List<Item>> getItems(String listId);
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
