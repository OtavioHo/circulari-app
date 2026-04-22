import 'list_color.dart';
import 'list_icon.dart';
import 'list_picture.dart';

class ItemList {
  final String id;
  final String name;
  final String? location;
  final ListColor color;
  final ListIcon icon;
  final ListPicture picture;
  final int itemCount;
  final double totalValue;
  final DateTime createdAt;

  const ItemList({
    required this.id,
    required this.name,
    this.location,
    required this.color,
    required this.icon,
    required this.picture,
    required this.itemCount,
    required this.totalValue,
    required this.createdAt,
  });
}
