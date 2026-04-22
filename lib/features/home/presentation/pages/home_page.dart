import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: CirculariListsCarousel(
        itemCount: 10,
        itemBuilder: (context, index) {
          final random = Random();
          final color = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );
          return CirculariListCard(
            title: 'Item $index',
            itemCount: 10,
            value: 42300.75,
            backgroundColor: color,
          );
        },
      ),
    );
  }
}
