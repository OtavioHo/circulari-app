import 'package:flutter/material.dart';

import '../../domain/entities/item_list.dart';

class ListCard extends StatelessWidget {
  final ItemList list;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        onLongPress: onRename,
        title: Text(list.name),
        subtitle: Text('${list.itemCount} items'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${list.totalValue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete list',
            ),
          ],
        ),
      ),
    );
  }
}
