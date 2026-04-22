import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final textFieldUseCases = [
  centeredUseCase(
    name: 'Default',
    builder: (context) => SizedBox(
      width: 320,
      child: CirculariTextField(
        label: context.knobs.string(label: 'Label', initialValue: 'Name'),
        hint: context.knobs.string(label: 'Hint', initialValue: 'Enter your name'),
      ),
    ),
  ),
  centeredUseCase(
    name: 'No label',
    builder: (context) => SizedBox(
      width: 320,
      child: CirculariTextField(
        hint: context.knobs.string(label: 'Hint', initialValue: 'Enter value'),
      ),
    ),
  ),
];
