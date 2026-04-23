import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.push('/lists/create'),
              child: Text('Add List'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/items/add'),
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
