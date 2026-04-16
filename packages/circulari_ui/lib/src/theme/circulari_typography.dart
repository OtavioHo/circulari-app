import 'dart:ui';

import 'package:flutter/material.dart';

class CirculariTypography {
  final TextStyle headline1;
  final TextStyle headline2;
  final TextStyle headline3;
  final TextStyle body;

  const CirculariTypography({
    required this.headline1,
    required this.headline2,
    required this.headline3,
    required this.body,
  });
}

const circulariTypography = CirculariTypography(
  headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  headline3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  body: TextStyle(fontSize: 14),
);
