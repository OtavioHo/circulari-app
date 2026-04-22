import '../../domain/entities/list_color.dart';

class ListColorModel extends ListColor {
  const ListColorModel({
    required super.hexCode,
    required super.name,
    required super.order,
  });

  factory ListColorModel.fromJson(Map<String, dynamic> json) => ListColorModel(
        hexCode: json['hex_code'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
      );
}
