import 'item_image.dart';

class Item {
  final String id;
  final String listId;
  final String name;
  final String? description;
  final int quantity;
  final String? locationId;
  final double? userDefinedValue;
  final List<ItemImage> images;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.listId,
    required this.name,
    this.description,
    required this.quantity,
    this.locationId,
    this.userDefinedValue,
    required this.images,
    required this.createdAt,
  });
}
