import 'package:flutter/material.dart';

import '../../domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddImage;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: _ItemThumbnail(item: item, onAddImage: onAddImage),
        title: Text(item.name),
        subtitle: _subtitle(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.userDefinedValue != null)
              Text(
                'R\$ ${item.userDefinedValue!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit item',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete item',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _subtitle(BuildContext context) {
    final parts = <String>[
      if (item.quantity > 1) 'Qty: ${item.quantity}',
      if (item.description != null && item.description!.isNotEmpty)
        item.description!,
    ];
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final Item item;
  final VoidCallback onAddImage;

  const _ItemThumbnail({required this.item, required this.onAddImage});

  @override
  Widget build(BuildContext context) {
    if (item.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.images.first.url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(context),
        ),
      );
    }
    return GestureDetector(
      onTap: onAddImage,
      child: _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add_a_photo_outlined,
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
