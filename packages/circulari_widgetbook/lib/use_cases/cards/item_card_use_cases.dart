import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final itemCardUseCases = [
  centeredUseCase(
    name: 'Default',
    builder: (context) => CirculariItemCard(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.knobs.string(label: 'Content', initialValue: 'Item title'),
        ),
      ),
    ),
  ),
  centeredUseCase(
    name: 'Not tappable',
    builder: (context) => CirculariItemCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.knobs.string(label: 'Content', initialValue: 'Item title'),
        ),
      ),
    ),
  ),
];
