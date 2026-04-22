import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final searchFieldUseCases = [
  centeredUseCase(
    name: 'Default',
    builder: (context) => SizedBox(
      width: 320,
      child: CirculariSearchField(
        hint: context.knobs.string(label: 'Hint', initialValue: 'Search items...'),
      ),
    ),
  ),
];
