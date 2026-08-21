import 'package:bloc_test/bloc_test.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/items_state.dart';
import 'package:circulari/features/lists/presentation/pages/list_detail_page.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsBloc extends MockBloc<ItemsEvent, ItemsState>
    implements ItemsBloc {}

Widget _makeTestable(ItemsBloc bloc) => MaterialApp(
      theme: circulariLightThemeData,
      home: BlocProvider<ItemsBloc>.value(
        value: bloc,
        child: const ListDetailPage(listId: 'list-1', listName: 'Groceries'),
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const ItemsLoadMoreRequested('list-1'));
  });

  late MockItemsBloc bloc;
  final item = tItem(id: 'a');

  setUp(() => bloc = MockItemsBloc());

  // A load-more failure closes the auto-dispatch gate in _maybeLoadMore so a
  // failing server isn't retried once per scroll frame. Nothing reopens it on
  // its own, so the end-of-list tile is the only recovery that outlives the
  // snackbar — without it, missing the snackbar leaves the list permanently
  // truncated until the route is reopened.
  group('load-more failure recovery', () {
    testWidgets('shows a retry tile at the end of the list', (tester) async {
      whenListen(
        bloc,
        const Stream<ItemsState>.empty(),
        initialState: ItemsSuccess(
          [item],
          nextCursor: 'cur-1',
          loadMoreError: 'No internet connection.',
        ),
      );

      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pump();

      expect(find.text('No internet connection.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('tapping the retry tile dispatches ItemsLoadMoreRequested',
        (tester) async {
      whenListen(
        bloc,
        const Stream<ItemsState>.empty(),
        initialState: ItemsSuccess(
          [item],
          nextCursor: 'cur-1',
          loadMoreError: 'No internet connection.',
        ),
      );

      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pump();
      await tester.tap(find.text('Tentar novamente'));

      verify(() => bloc.add(any(that: isA<ItemsLoadMoreRequested>())))
          .called(1);
    });

    testWidgets('shows no retry tile while pagination is healthy',
        (tester) async {
      whenListen(
        bloc,
        const Stream<ItemsState>.empty(),
        initialState: ItemsSuccess([item], nextCursor: 'cur-1'),
      );

      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pump();

      expect(find.text('Tentar novamente'), findsNothing);
    });
  });
}
