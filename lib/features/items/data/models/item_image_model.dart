import '../../domain/entities/item_image.dart';

class ItemImageModel extends ItemImage {
  const ItemImageModel({
    required super.id,
    required super.itemId,
    required super.url,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json, String itemId) =>
      ItemImageModel(
        id: json['id'] as String,
        itemId: itemId,
        url: json['url'] as String,
      );
}
