import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import 'item_image_model.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.listId,
    required super.name,
    super.description,
    required super.quantity,
    super.locationId,
    super.userDefinedValue,
    super.category,
    required super.images,
    required super.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawImages = json['images'] as List? ?? [];

    final rawCategory = json['category'];
    Category? category;
    if (rawCategory is Map<String, dynamic>) {
      category = Category(
        id: rawCategory['id'] as String,
        name: rawCategory['name'] as String,
      );
    }

    return ItemModel(
      id: id,
      listId: json['list_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      locationId: json['location_id'] as String?,
      userDefinedValue: json['user_defined_value'] != null
          ? (json['user_defined_value'] as num).toDouble()
          : null,
      category: category,
      images: rawImages
          .map((e) => ItemImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
