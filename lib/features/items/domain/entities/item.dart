import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item_image.dart';
import 'package:circulari/features/items/domain/entities/list_info.dart';

class Item {
  final String id;
  final String listId;
  final String name;
  final String? description;
  final int quantity;
  final String? locationId;
  final double? userDefinedValue;
  final Category? category;
  final List<ItemImage> images;
  final ListInfo? listInfo;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.listId,
    required this.name,
    this.description,
    required this.quantity,
    this.locationId,
    this.userDefinedValue,
    this.category,
    required this.images,
    this.listInfo,
    required this.createdAt,
  });
}
