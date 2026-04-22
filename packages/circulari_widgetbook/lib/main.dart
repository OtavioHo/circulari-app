import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/buttons/primary_button_use_cases.dart';
import 'use_cases/buttons/secondary_button_use_cases.dart';
import 'use_cases/cards/item_card_use_cases.dart';
import 'use_cases/cards/list_card_use_cases.dart';
import 'use_cases/inputs/search_field_use_cases.dart';
import 'use_cases/inputs/text_field_use_cases.dart';
import 'use_cases/navigation/bottom_nav_bar_use_cases.dart';

void main() => runApp(const WidgetbookApp());

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Buttons',
          children: [
            WidgetbookComponent(
              name: 'PrimaryButton',
              useCases: primaryButtonUseCases,
            ),
            WidgetbookComponent(
              name: 'SecondaryButton',
              useCases: secondaryButtonUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Inputs',
          children: [
            WidgetbookComponent(
              name: 'TextField',
              useCases: textFieldUseCases,
            ),
            WidgetbookComponent(
              name: 'SearchField',
              useCases: searchFieldUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Cards',
          children: [
            WidgetbookComponent(
              name: 'ItemCard',
              useCases: itemCardUseCases,
            ),
            WidgetbookComponent(
              name: 'ListCard',
              useCases: listCardUseCases,
            ),
            WidgetbookComponent(
              name: 'ListsCarousel',
              useCases: listsCarouselUseCases,
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Navigation',
          children: [
            WidgetbookComponent(
              name: 'BottomNavBar',
              useCases: bottomNavBarUseCases,
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: circulariLightThemeData),
            WidgetbookTheme(name: 'Dark', data: circulariDarkThemeData),
          ],
        ),
        TextScaleAddon(),
      ],
    );
  }
}
