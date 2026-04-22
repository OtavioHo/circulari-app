import 'package:circulari_ui/circulari_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../utils/centered_use_case.dart';

final secondaryButtonUseCases = [
  centeredUseCase(
    name: 'Enabled',
    builder: (context) => CirculariSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Cancel'),
      onPressed: () {},
    ),
  ),
  centeredUseCase(
    name: 'Disabled',
    builder: (context) => CirculariSecondaryButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Cancel'),
      onPressed: null,
    ),
  ),
];
