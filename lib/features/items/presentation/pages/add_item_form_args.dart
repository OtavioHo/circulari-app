import 'package:circulari/features/lists/domain/entities/item_list.dart';

class AddItemFormArgs {
  final String listId;
  final String imagePath;
  final ItemList? list;

  const AddItemFormArgs({
    required this.listId,
    required this.imagePath,
    this.list,
  });
}
