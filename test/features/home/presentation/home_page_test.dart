import 'package:bloc_test/bloc_test.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_event.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_state.dart';
import 'package:circulari/features/home/presentation/pages/home_page.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_event.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_state.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_event.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_state.dart';

class MockListsBloc extends MockBloc<ListsEvent, ListsState>
    implements ListsBloc {}

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockSearchItemsBloc
    extends MockBloc<SearchItemsEvent, SearchItemsState>
    implements SearchItemsBloc {}

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
  required AuthStateNotifier authNotifier,
}) {
  return MaterialApp(
    theme: circulariLightThemeData,
    home: DefaultAssetBundle(
      bundle: _StubAssetBundle(),
      child: ChangeNotifierProvider<AuthStateNotifier>.value(
        value: authNotifier,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ListsBloc>.value(value: listsBloc),
            BlocProvider<DashboardBloc>.value(value: dashboardBloc),
            BlocProvider<SearchItemsBloc>.value(value: searchItemsBloc),
          ],
          child: const Scaffold(body: HomePage()),
        ),
      ),
    ),
  );
}

void main() {
  late MockListsBloc listsBloc;
  late MockDashboardBloc dashboardBloc;
  late MockSearchItemsBloc searchItemsBloc;

  setUp(() {
    listsBloc = MockListsBloc();
    dashboardBloc = MockDashboardBloc();
    searchItemsBloc = MockSearchItemsBloc();
    when(() => listsBloc.state).thenReturn(ListsSuccess(const []));
    when(() => dashboardBloc.state).thenReturn(const DashboardInitial());
    when(() => searchItemsBloc.state).thenReturn(const SearchItemsInitial());
  });

  testWidgets('greets the user by first name from AuthStateNotifier',
      (tester) async {
    final auth = AuthStateNotifier(true)..setUserName('Otavio Aragoni');

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
      authNotifier: auth,
    ));

    expect(find.text('Olá, Otavio!'), findsOneWidget);
  });

  testWidgets('falls back to a plain greeting when the user name is unset',
      (tester) async {
    // Cold start before /me resolves (or right after logout): userName is
    // null and the greeting must not render the literal "Olá, !".
    final auth = AuthStateNotifier(true);

    await tester.pumpWidget(_makeTestable(
      listsBloc: listsBloc,
      dashboardBloc: dashboardBloc,
      searchItemsBloc: searchItemsBloc,
      authNotifier: auth,
    ));

    expect(find.text('Olá!'), findsOneWidget);
    expect(find.textContaining('Olá, '), findsNothing);
  });
}
