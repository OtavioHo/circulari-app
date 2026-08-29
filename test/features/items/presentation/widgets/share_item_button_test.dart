import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/presentation/bloc/share_item_cubit.dart';
import 'package:circulari/features/items/presentation/widgets/share_item_button.dart';

import '../../../../helpers/pump_app.dart';

class MockShareItemCubit extends MockCubit<ShareItemState>
    implements ShareItemCubit {}

void main() {
  late MockShareItemCubit cubit;

  setUp(() {
    cubit = MockShareItemCubit();
    when(() => cubit.share(any())).thenAnswer((_) async {});
  });

  Future<void> pumpButton(WidgetTester tester, {bool disabled = false}) =>
      tester.pumpApp(
        BlocProvider<ShareItemCubit>.value(
          value: cubit,
          child: ShareItemButton(itemId: 'item-1', disabled: disabled),
        ),
      );

  testWidgets('dispatches to the cubit instead of calling the API itself',
      (tester) async {
    whenListen(cubit, const Stream<ShareItemState>.empty(),
        initialState: const ShareItemInitial());

    await pumpButton(tester);
    await tester.tap(find.byType(IconButton));

    verify(() => cubit.share('item-1')).called(1);
  });

  testWidgets('shows progress in place of the glyph while sharing',
      (tester) async {
    whenListen(cubit, const Stream<ShareItemState>.empty(),
        initialState: const ShareItemLoading());

    await pumpButton(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.ios_share_outlined), findsNothing);
    // Disabled while in flight, so a second tap cannot open a second sheet.
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  testWidgets('is disabled while the page itself is busy', (tester) async {
    whenListen(cubit, const Stream<ShareItemState>.empty(),
        initialState: const ShareItemInitial());

    await pumpButton(tester, disabled: true);

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  testWidgets('snackbars a failure and keeps the button usable',
      (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable(const [ShareItemFailure('Sem conexão')]),
      initialState: const ShareItemInitial(),
    );

    await pumpButton(tester);
    await tester.pump();

    expect(find.text('Sem conexão'), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
  });
}
