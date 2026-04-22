import 'package:flutter/material.dart';

const Map<String, IconData> listIconMap = {
  'shopping': Icons.shopping_cart,
  'home': Icons.home,
  'work': Icons.work,
  'travel': Icons.flight,
  'food': Icons.restaurant,
  'electronics': Icons.devices,
  'clothing': Icons.checkroom,
  'sports': Icons.sports,
  'health': Icons.health_and_safety,
  'education': Icons.school,
  'finance': Icons.account_balance_wallet,
  'entertainment': Icons.movie,
  'garden': Icons.yard,
  'tools': Icons.build,
  'pets': Icons.pets,
  'gift': Icons.card_giftcard,
  'books': Icons.menu_book,
  'music': Icons.music_note,
  'art': Icons.palette,
  'car': Icons.directions_car,
};

IconData iconForSlug(String slug) =>
    listIconMap[slug] ?? Icons.category;
