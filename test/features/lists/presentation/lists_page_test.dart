import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/lists/domain/entities/item_list.dart';
import 'package:app/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:app/features/lists/presentation/bloc/lists_event.dart';
import 'package:app/features/lists/presentation/bloc/lists_state.dart';
import 'package:app/features/lists/presentation/pages/lists_page.dart';

class MockListsBloc extends MockBloc<ListsEvent, ListsState>
    implements ListsBloc {}

final _tList = ItemList(
  id: 'abc',
  name: 'Groceries',
  itemCount: 5,
  totalValue: 200.0,
  createdAt: DateTime(2024),
);

Widget _makeTestable(ListsBloc bloc) => MaterialApp(
      home: BlocProvider<ListsBloc>.value(
        value: bloc,
        child: const ListsPage(),
      ),
    );

void main() {
  // Required so any() and captureAny() know the fallback type for ListsEvent.
  setUpAll(() => registerFallbackValue(const ListsLoadRequested()));

  late MockListsBloc bloc;

  setUp(() => bloc = MockListsBloc());

  testWidgets('shows loading indicator for ListsLoading', (tester) async {
    when(() => bloc.state).thenReturn(ListsLoading());

    await tester.pumpWidget(_makeTestable(bloc));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty message when list is empty', (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([]));

    await tester.pumpWidget(_makeTestable(bloc));

    expect(find.text('No lists yet. Tap + to create one.'), findsOneWidget);
  });

  testWidgets('shows list cards when lists are loaded', (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('5 items'), findsOneWidget);
  });

  testWidgets('shows error message and retry button on failure', (tester) async {
    when(() => bloc.state)
        .thenReturn(ListsFailure('No internet connection.'));

    await tester.pumpWidget(_makeTestable(bloc));

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry button dispatches ListsLoadRequested', (tester) async {
    when(() => bloc.state).thenReturn(ListsFailure('Error'));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.tap(find.text('Retry'));

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsLoadRequested>());
  });

  testWidgets('delete button dispatches ListsDeleteRequested with correct id',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.tap(find.byIcon(Icons.delete_outline));

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsDeleteRequested>());
    expect((captured.single as ListsDeleteRequested).id, 'abc');
  });

  testWidgets('FAB opens dialog and dispatches ListsCreateRequested',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tools');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsCreateRequested>());
    expect((captured.single as ListsCreateRequested).name, 'Tools');
  });

  testWidgets('long press opens rename dialog and dispatches ListsRenameRequested',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.longPress(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    // Clear the pre-filled value and type the new name.
    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsRenameRequested>());
    expect((captured.single as ListsRenameRequested).name, 'Renamed');
  });
}
