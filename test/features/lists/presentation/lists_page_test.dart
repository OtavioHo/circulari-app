import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/lists/domain/entities/item_list.dart';
import 'package:app/features/lists/domain/entities/list_color.dart';
import 'package:app/features/lists/domain/entities/list_icon.dart';
import 'package:app/features/lists/domain/entities/list_picture.dart';
import 'package:app/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:app/features/lists/presentation/bloc/lists_event.dart';
import 'package:app/features/lists/presentation/bloc/lists_state.dart';
import 'package:app/features/lists/presentation/pages/lists_page.dart';

class MockListsBloc extends MockBloc<ListsEvent, ListsState>
    implements ListsBloc {}

final _tColor = ListColor(hexCode: '#FF0000', name: 'Red', order: 0);
final _tIcon = ListIcon(slug: 'home', name: 'Home', order: 0);
final _tPicture = ListPicture(slug: 'nature', order: 0);

final _tList = ItemList(
  id: 'abc',
  name: 'Groceries',
  color: _tColor,
  icon: _tIcon,
  picture: _tPicture,
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

  testWidgets('delete button opens confirmation dialog; '
      'confirming dispatches ListsDeleteRequested with correct id',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Delete list'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsDeleteRequested>());
    expect((captured.single as ListsDeleteRequested).id, 'abc');
  });

  testWidgets('cancelling the delete dialog does not dispatch any event',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(any()));
  });

  testWidgets('long press opens rename dialog and dispatches ListsRenameRequested',
      (tester) async {
    when(() => bloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(bloc));
    await tester.longPress(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsRenameRequested>());
    expect((captured.single as ListsRenameRequested).name, 'Renamed');
  });
}
