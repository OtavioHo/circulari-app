import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/domain/entities/list_picture.dart';

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

  static const _unset = Object();

  /// [location] is clearable: pass `null` explicitly to erase it.
  ItemList copyWith({
    String? name,
    Object? location = _unset,
    ListColor? color,
    ListIcon? icon,
    ListPicture? picture,
  }) => ItemList(
        id: id,
        name: name ?? this.name,
        location:
            identical(location, _unset) ? this.location : location as String?,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        picture: picture ?? this.picture,
        itemCount: itemCount,
        totalValue: totalValue,
        createdAt: createdAt,
      );
}
