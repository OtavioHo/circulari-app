import '../entities/item.dart';

abstract interface class ItemsRepository {
  Future<List<Item>> getItems(String listId);
  Future<Item> createItem({
    required String listId,
    required String name,
    String? description,
    int quantity,
    String? locationId,
    double? userDefinedValue,
  });
  Future<Item> updateItem(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? locationId,
    double? userDefinedValue,
  });
  Future<void> deleteItem(String id);
  Future<Item> uploadItemImage(String itemId, String imagePath);
}
