import 'package:flutter/material.dart';

/// Maps an item category name to a representative icon.
///
/// Matching is case-insensitive and trimmed. Unknown or empty categories fall
/// back to a generic item icon.
IconData categoryIcon(String? categoryName) {
  final key = (categoryName ?? '').trim().toLowerCase();
  return _categoryIcons[key] ?? Icons.inventory_2_outlined;
}

const _categoryIcons = <String, IconData>{
  'móveis': Icons.chair_outlined,
  'eletrônicos': Icons.devices_other_outlined,
  'smartphones': Icons.smartphone,
  'computadores': Icons.computer_outlined,
  'roupas': Icons.checkroom,
  'acessórios': Icons.watch_outlined,
  'sapatos': Icons.ice_skating,
  'cozinha': Icons.kitchen_outlined,
  'decoração': Icons.format_paint_outlined,
  'livros': Icons.menu_book_outlined,
  'filmes': Icons.movie_outlined,
  'ferramentas': Icons.handyman_outlined,
  'máquinas': Icons.precision_manufacturing,
  'artigos esportivos': Icons.sports_soccer,
  'colecionáveis': Icons.collections_outlined,
  'artes': Icons.palette_outlined,
  'bebidas': Icons.local_bar_outlined,
  'outros': Icons.category_outlined,
};
