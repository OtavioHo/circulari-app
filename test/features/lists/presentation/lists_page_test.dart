import 'package:bloc_test/bloc_test.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:app/core/auth/auth_state_notifier.dart';
import 'package:app/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:app/features/home/presentation/bloc/dashboard_event.dart';
import 'package:app/features/home/presentation/bloc/dashboard_state.dart';
import 'package:app/features/items/presentation/bloc/search_items_bloc.dart';
import 'package:app/features/items/presentation/bloc/search_items_event.dart';
import 'package:app/features/items/presentation/bloc/search_items_state.dart';
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

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockSearchItemsBloc
    extends MockBloc<SearchItemsEvent, SearchItemsState>
    implements SearchItemsBloc {}

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

// 1x1 transparent PNG for asset image stubs.
final Uint8List _kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

const _kEmptySvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>';

class _StubAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final encoded =
          const StandardMessageCodec().encodeMessage(<String, Object>{})!;
      return encoded;
    }
    if (key.toLowerCase().endsWith('.svg')) {
      final bytes = Uint8List.fromList(_kEmptySvg.codeUnits);
      return ByteData.view(bytes.buffer);
    }
    return ByteData.view(_kTransparentPng.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.toLowerCase().endsWith('.svg')) return _kEmptySvg;
    return '';
  }
}

Widget _makeTestable({
  required ListsBloc listsBloc,
  required DashboardBloc dashboardBloc,
  required SearchItemsBloc searchItemsBloc,
  AuthStateNotifier? authNotifier,
}) {
  return MaterialApp(
    theme: circulariLightThemeData,
    home: DefaultAssetBundle(
      bundle: _StubAssetBundle(),
      child: ChangeNotifierProvider<AuthStateNotifier>.value(
        value: authNotifier ?? AuthStateNotifier(true),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ListsBloc>.value(value: listsBloc),
            BlocProvider<DashboardBloc>.value(value: dashboardBloc),
            BlocProvider<SearchItemsBloc>.value(value: searchItemsBloc),
          ],
          child: const Scaffold(body: ListsPage()),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ListsLoadRequested());
    registerFallbackValue(const DashboardLoadRequested());
    registerFallbackValue(const SearchItemsLoadRequested());
  });

  late MockListsBloc listsBloc;
  late MockDashboardBloc dashboardBloc;
  late MockSearchItemsBloc searchItemsBloc;

  setUp(() {
    listsBloc = MockListsBloc();
    dashboardBloc = MockDashboardBloc();
    searchItemsBloc = MockSearchItemsBloc();

    when(() => dashboardBloc.state).thenReturn(const DashboardInitial());
    when(() => searchItemsBloc.state).thenReturn(const SearchItemsInitial());
  });

  testWidgets('shows loading indicator for ListsLoading', (tester) async {
    when(() => listsBloc.state).thenReturn(const ListsLoading());

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('renders carousel with one card per list on ListsSuccess',
      (tester) async {
    when(() => listsBloc.state).thenReturn(ListsSuccess([_tList]));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));

    expect(find.byType(CirculariListsCarousel), findsOneWidget);
    expect(find.byType(CirculariListCard), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('renders carousel for ListsActionFailure preserving lists',
      (tester) async {
    when(() => listsBloc.state)
        .thenReturn(ListsActionFailure([_tList], 'oops'));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));

    expect(find.byType(CirculariListCard), findsOneWidget);
  });

  testWidgets('shows error message and Retry button on ListsFailure',
      (tester) async {
    when(() => listsBloc.state)
        .thenReturn(const ListsFailure('No internet connection.'));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
  });

  testWidgets('lists Retry button dispatches ListsLoadRequested',
      (tester) async {
    when(() => listsBloc.state).thenReturn(const ListsFailure('Error'));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry').first);

    final captured = verify(() => listsBloc.add(captureAny())).captured;
    expect(captured.single, isA<ListsLoadRequested>());
  });

  testWidgets('search Retry button dispatches SearchItemsLoadRequested',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    when(() => listsBloc.state).thenReturn(ListsSuccess([_tList]));
    when(() => searchItemsBloc.state)
        .thenReturn(const SearchItemsFailure('Network error'));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));

    final captured = verify(() => searchItemsBloc.add(captureAny())).captured;
    expect(captured.single, isA<SearchItemsLoadRequested>());
  });

  testWidgets('renders user name from AuthStateNotifier in header',
      (tester) async {
    final auth = AuthStateNotifier(true)..setUserName('Otavio');
    when(() => listsBloc.state).thenReturn(ListsSuccess(const []));

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
      authNotifier: auth,
    ));

    expect(find.text('Olá, Otavio!'), findsOneWidget);
  });
}
