import '../../domain/entities/list_icon.dart';

class ListIconModel extends ListIcon {
  const ListIconModel({
    required super.slug,
    required super.name,
    required super.order,
  });

  factory ListIconModel.fromJson(Map<String, dynamic> json) => ListIconModel(
        slug: json['slug'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
      );
}
