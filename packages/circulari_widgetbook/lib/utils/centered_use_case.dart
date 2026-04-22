import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookUseCase centeredUseCase({
  required String name,
  required Widget Function(BuildContext) builder,
}) {
  return WidgetbookUseCase(
    name: name,
    builder: (context) => Center(child: builder(context)),
  );
}
