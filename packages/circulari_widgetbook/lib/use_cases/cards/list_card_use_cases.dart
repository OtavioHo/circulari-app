import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final _sampleColors = [
  const Color(0xFFD4E6FF),
  const Color(0xFFD4F5E4),
  const Color(0xFFFFE8CC),
  const Color(0xFFF5D4F5),
  const Color(0xFFFFD4D4),
];

final listCardUseCases = [
  centeredUseCase(
    name: 'Default',
    builder: (context) => CirculariListCard(
      title: context.knobs.string(label: 'Title', initialValue: 'Mercado'),
      itemCount: context.knobs.string(label: 'Item count', initialValue: '12 items'),
      valueLabel: context.knobs.string(label: 'Value label', initialValue: 'Total'),
      value: context.knobs.string(label: 'Value', initialValue: 'R\$ 340,00'),
      backgroundColor: context.knobs.color(
        label: 'Background color',
        initialValue: const Color(0xFFD4E6FF),
      ),
      isValueHidden: context.knobs.boolean(label: 'Hide value', initialValue: false),
      seed: context.knobs.int.input(label: 'Wave seed', initialValue: 42),
    ),
  ),
];

final listsCarouselUseCases = [
  WidgetbookUseCase(
    name: 'Default',
    builder: (context) => CirculariListsCarousel(
      itemCount: _sampleColors.length,
      itemBuilder: (context, index) => CirculariListCard(
        title: ['Mercado', 'Casa', 'Trabalho', 'Lazer', 'Saúde'][index],
        itemCount: ['12 items', '8 items', '5 items', '20 items', '3 items'][index],
        valueLabel: 'Total',
        value: ['R\$ 340,00', 'R\$ 1.200,00', 'R\$ 89,90', 'R\$ 450,00', 'R\$ 75,50'][index],
        backgroundColor: _sampleColors[index],
        seed: index,
      ),
    ),
  ),
];
