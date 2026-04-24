import 'package:circulari_ui/circulari_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final buttonUseCases = [
  centeredUseCase(
    name: 'Enabled',
    builder: (context) => CirculariButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Confirm'),
      onPressed: () {},
    ),
  ),
  centeredUseCase(
    name: 'Disabled',
    builder: (context) => CirculariButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Confirm'),
      onPressed: null,
    ),
  ),
];
