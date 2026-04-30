import 'package:circulari/features/items/domain/entities/item_image.dart';

class ItemImageModel extends ItemImage {
  const ItemImageModel({
    required super.url,
    required super.isMain,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) => ItemImageModel(
        url: json['url'] as String,
        isMain: json['is_main'] as bool? ?? false,
      );
}
