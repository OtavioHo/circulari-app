import '../../domain/entities/item_list.dart';

class ListModel extends ItemList {
  const ListModel({
    required super.id,
    required super.name,
    required super.itemCount,
    required super.totalValue,
    required super.createdAt,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        id: json['id'] as String,
        name: json['name'] as String,
        itemCount: json['item_count'] as int,
        totalValue: (json['total_value'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
