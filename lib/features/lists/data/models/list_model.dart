import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/data/models/list_color_model.dart';
import 'package:circulari/features/lists/data/models/list_icon_model.dart';
import 'package:circulari/features/lists/data/models/list_picture_model.dart';

class ListModel extends ItemList {
  const ListModel({
    required super.id,
    required super.name,
    super.location,
    required super.color,
    required super.icon,
    required super.picture,
    required super.itemCount,
    required super.totalValue,
    required super.createdAt,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String?,
        color: ListColorModel.fromJson(json['color'] as Map<String, dynamic>),
        icon: ListIconModel.fromJson(json['icon'] as Map<String, dynamic>),
        picture:
            ListPictureModel.fromJson(json['picture'] as Map<String, dynamic>),
        itemCount: json['item_count'] as int,
        totalValue: (json['total_value'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
