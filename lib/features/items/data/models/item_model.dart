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
    required super.images,
    required super.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawImages = json['images'] as List? ?? [];
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
      images: rawImages
          .map((e) => ItemImageModel.fromJson(e as Map<String, dynamic>, id))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
