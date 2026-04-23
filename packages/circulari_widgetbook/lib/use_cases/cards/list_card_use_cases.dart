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
      backgroundColor: context.knobs.color(
        label: 'Background color',
        initialValue: const Color(0xFFD4E6FF),
      ),
      isValueHidden: context.knobs.boolean(
        label: 'Hide value',
        initialValue: false,
      ),
      seed: context.knobs.int.input(label: 'Wave seed', initialValue: 42),
      itemCount: 50,
      value: 42333.75,
      picturePath: '',
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
        backgroundColor: _sampleColors[index],
        seed: index,
        itemCount: 42,
        value: 42,
        picturePath: '',
      ),
    ),
  ),
];
