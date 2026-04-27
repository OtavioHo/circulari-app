import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? _selected;

  void _onCreate() {
    if (_selected == 'Item') {
      context.push('/items/add');
    } else if (_selected == 'Lista') {
      context.push('/lists/create');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CirculariInAppScaffold(
      onBackPressed: () => context.go('/home'),
      title: 'Criar',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cria sua lista/item',
              style: context.circulariTheme.typography.heading3.copyWith(
                color: CirculariColorsTokens.greyscale900,
              ),
            ),
            Text(
              'Escolha para criar um item ou lista.',
              style: context.circulariTheme.typography.body.medium.regular
                  .copyWith(color: CirculariColorsTokens.greyscale500),
            ),
            SizedBox(height: context.circulariTheme.spacing.xLarge),
            CirculariSelectBox<String>(
              options: [
                CirculariSelectOption(label: 'Item', value: 'Item'),
                CirculariSelectOption(label: 'Lista', value: 'Lista'),
              ],
              selected: _selected,
              onSelected: (value) => setState(() => _selected = value),
            ),
            const Spacer(),

            if (_selected != null)
              CirculariButton(label: 'Criar', onPressed: _onCreate),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
