import 'package:flutter/material.dart';

const Map<String, Color> listPictureColorMap = {
  'nature': Color(0xFF4CAF50),
  'city': Color(0xFF607D8B),
  'beach': Color(0xFF03A9F4),
  'mountains': Color(0xFF795548),
  'space': Color(0xFF1A1A2E),
  'forest': Color(0xFF2E7D32),
  'desert': Color(0xFFFF8F00),
  'ocean': Color(0xFF0277BD),
  'sunset': Color(0xFFE64A19),
  'winter': Color(0xFF90CAF9),
  'abstract': Color(0xFF7B1FA2),
  'minimal': Color(0xFF455A64),
};

const Map<String, String> listPictureAssetMap = {
  'beach_house': 'assets/images/list_pictures/beach_house.png',
  'storage': 'assets/images/list_pictures/storage.png',
  'country_house': 'assets/images/list_pictures/country_house.png',
  'assets': 'assets/images/list_pictures/assets.png',
};

Color colorForSlug(String slug) =>
    listPictureColorMap[slug] ?? const Color(0xFF9E9E9E);

String? assetForSlug(String slug) => listPictureAssetMap[slug];
