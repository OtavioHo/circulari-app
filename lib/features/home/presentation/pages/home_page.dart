import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CirculariCollapsibleBody(
      expandedHeight: 200,
      collapsedHeight: 87,
      headerBuilder: (context, shrinkOffset) {
        final typography = context.circulariTheme.typography;
        final spacing = context.circulariTheme.spacing;
        const maxShrink = 200.0 - 87.0;
        final t = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

        return Stack(
          children: [
            Opacity(
              opacity: (1 - t * 2).clamp(0.0, 1.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.medium,
                  spacing.large,
                  spacing.medium,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo',
                      style: typography.heading2.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: spacing.medium),
                    Text(
                      'Total de bens listados',
                      style: typography.body.medium.regular,
                    ),
                    Text(
                      'R\$ 123.456,78',
                      style: typography.heading1.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.medium,
                    0,
                    spacing.medium,
                    spacing.medium,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de bens listados',
                        style: typography.body.medium.regular,
                      ),
                      Text(
                        'R\$ 123.456,78',
                        style: typography.heading1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      children: [
        CirculariListsCarousel(
          itemCount: 10,
          itemBuilder: (context, index) {
            final random = Random();
            final color = Color.fromARGB(
              255,
              random.nextInt(256),
              random.nextInt(256),
              random.nextInt(256),
            );
            return CirculariListCard(
              title: 'Item $index',
              itemCount: 10,
              value: 42300.75,
              backgroundColor: color,
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.circulariTheme.spacing.medium,
          ),
          child: Text(
            "Items recentes",
            style: context.circulariTheme.typography.body.xLarge.bold.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
        ),
        ...List.generate(
          20,
          (index) => ListTile(
            title: Text('List Item $index'),
            subtitle: Text('Subtitle for item $index'),
            leading: CircleAvatar(child: Text('$index')),
          ),
        ),
      ],
    );
  }
}
