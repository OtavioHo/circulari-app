import 'package:flutter/material.dart';

const Map<String, IconData> listIconMap = {
  'list': Icons.list,
  'shopping-cart': Icons.shopping_cart,
  'home': Icons.home,
  'gift': Icons.card_giftcard,
  'tag': Icons.label,
  'briefcase': Icons.work,
  'heart': Icons.favorite,
  'star': Icons.star,
  'book': Icons.book,
  'tool': Icons.build,
};

const listIcons = [
  {'slug': 'list', 'name': 'Lista', 'order': 0},
  {'slug': 'shopping-cart', 'name': 'Carrinho', 'order': 1},
  {'slug': 'home', 'name': 'Casa', 'order': 2},
  {'slug': 'gift', 'name': 'Presente', 'order': 3},
  {'slug': 'tag', 'name': 'Etiqueta', 'order': 4},
  {'slug': 'briefcase', 'name': 'Maleta', 'order': 5},
  {'slug': 'heart', 'name': 'Coração', 'order': 6},
  {'slug': 'star', 'name': 'Estrela', 'order': 7},
  {'slug': 'book', 'name': 'Livro', 'order': 8},
  {'slug': 'tool', 'name': 'Ferramenta', 'order': 9},
];

IconData iconForSlug(String slug) =>
    listIconMap[slug] ?? Icons.category;
