// Renders the Planos paywall with injected plan data to produce App Store /
// Play review screenshots — no device, RevenueCat, or login required.
//
// Generate the PNGs with:
//   flutter test --update-goldens test/screenshots/paywall_screenshot_test.dart
// Output: test/screenshots/goldens/paywall_*.png
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_bloc.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_event.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_state.dart';
import 'package:circulari/features/subscription/presentation/pages/plans_page.dart';

class MockPaywallBloc extends MockBloc<PaywallEvent, PaywallState>
    implements PaywallBloc {}

// google_fonts is told not to fetch at runtime (tests have no network), so it
// falls back to looking each font up in the root bundle's asset manifest. The
// app doesn't bundle the TTFs — google_fonts downloads them in production — so
// the test serves a synthetic manifest, plus the TTFs checked in under
// [_kFontDir], over the asset channel. google_fonts then registers every
// weight itself under the "<Family>_<variant>" names the theme references.
const _kFontDir = 'test/screenshots/fonts';

/// Weight names google_fonts builds its asset filenames from
/// (`<Family>-<part>.ttf`), mapped to the TTF on disk that covers each one.
/// Poppins ships as static per-weight files, so weights without their own file
/// borrow the nearest one; Montserrat is a single variable font.
const _kPoppinsFileForWeight = <String, String>{
  'Thin': 'Poppins-Regular',
  'ExtraLight': 'Poppins-Regular',
  'Light': 'Poppins-Regular',
  'Regular': 'Poppins-Regular',
  'Medium': 'Poppins-Medium',
  'SemiBold': 'Poppins-SemiBold',
  'Bold': 'Poppins-Bold',
  'ExtraBold': 'Poppins-Bold',
  'Black': 'Poppins-Bold',
};

/// google_fonts' filename part for a weight+style, e.g. `SemiBold`,
/// `BoldItalic` — and plain `Italic` rather than `RegularItalic` for w400.
String _filenamePart(String weight, bool italic) {
  if (weight == 'Regular') return italic ? 'Italic' : 'Regular';
  return italic ? '${weight}Italic' : weight;
}

Future<void> _loadFonts() async {
  final cache = <String, Uint8List>{};
  Future<Uint8List> read(String file) async =>
      cache[file] ??= await File('$_kFontDir/$file.ttf').readAsBytes();

  // Every family/weight/style google_fonts might ask for, pointed at the
  // closest TTF we actually have.
  final fontAssets = <String, Uint8List>{};
  for (final weight in _kPoppinsFileForWeight.keys) {
    for (final italic in [false, true]) {
      final part = _filenamePart(weight, italic);
      fontAssets['fonts/Poppins-$part.ttf'] =
          await read(_kPoppinsFileForWeight[weight]!);
      fontAssets['fonts/Montserrat-$part.ttf'] = await read('Montserrat-Variable');
    }
  }

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // Everything the test doesn't serve itself — MaterialIcons above all — still
  // has to come from the engine's real bundle.
  final platform = messenger.delegate;
  ByteData encodeKey(String key) =>
      ByteData.view(Uint8List.fromList(utf8.encode(key)).buffer);

  // AssetManifest.bin is a StandardMessageCodec map keyed by asset path; only
  // the keys are read back (via AssetManifest.listAssets), so empty variant
  // lists are enough. Merged into the real manifest rather than replacing it.
  final realManifest = await platform.send(
    'flutter/assets',
    encodeKey('AssetManifest.bin'),
  );
  final manifest = const StandardMessageCodec().encodeMessage(<Object?, Object?>{
    if (realManifest != null)
      ...const StandardMessageCodec().decodeMessage(realManifest)!
          as Map<Object?, Object?>,
    for (final key in fontAssets.keys) key: const <Object?>[],
  })!;

  messenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = utf8.decode(
      message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
    );
    if (key == 'AssetManifest.bin') return manifest;
    final font = fontAssets[key];
    if (font != null) {
      return ByteData.view(font.buffer, font.offsetInBytes, font.lengthInBytes);
    }
    return platform.send('flutter/assets', message);
  });

  // The unsuffixed families are used as fontFamilyFallback by google_fonts and
  // as the Material default in [_app]; google_fonts never registers those, so
  // they stay manual.
  Future<void> register(String family, String file) async {
    final bytes = await read(file);
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await register('Poppins', 'Poppins-Regular');
  await register('Montserrat', 'Montserrat-Variable');

  // flutter test doesn't bundle MaterialIcons, so every Icon would paint as a
  // tofu box. These goldens double as store screenshots, so pull the real font
  // out of the SDK cache.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final icons = flutterRoot == null
      ? null
      : File('$flutterRoot/bin/cache/artifacts/material_fonts/'
          'MaterialIcons-Regular.otf');
  if (icons != null && icons.existsSync()) {
    final bytes = await icons.readAsBytes();
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

// Prices to display on the paywall render.
const _options = <SubscriptionOption>[
  SubscriptionOption(
    tier: PlanTier.essencial,
    period: BillingPeriod.monthly,
    packageId: 'essencial-monthly',
    title: 'Essencial Mensal',
    priceString: r'R$19,90',
  ),
  SubscriptionOption(
    tier: PlanTier.pro,
    period: BillingPeriod.monthly,
    packageId: 'pro-monthly',
    title: 'Pro Mensal',
    priceString: r'R$49,90',
  ),
  SubscriptionOption(
    tier: PlanTier.essencial,
    period: BillingPeriod.annual,
    packageId: 'essencial-annual',
    title: 'Essencial Anual',
    priceString: r'R$199,90',
  ),
  SubscriptionOption(
    tier: PlanTier.pro,
    period: BillingPeriod.annual,
    packageId: 'pro-annual',
    title: 'Pro Anual',
    priceString: r'R$499,90',
  ),
];

// 1x1 transparent PNG for any asset image the page requests.
final Uint8List _kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

const _kEmptySvg = '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>';

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

Widget _app(PaywallBloc bloc) => MaterialApp(
      debugShowCheckedModeBanner: false,
      // Give any text that falls back to the Material default (e.g. the
      // "Restaurar compras" TextButton) a real, loaded font so it renders as
      // text instead of tofu boxes. Explicit google_fonts styles are unaffected.
      theme: circulariLightThemeData.copyWith(
        textTheme: circulariLightThemeData.textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: DefaultAssetBundle(
        bundle: _StubAssetBundle(),
        child: BlocProvider<PaywallBloc>.value(
          value: bloc,
          child: const PlansPage(),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    registerFallbackValue(const PaywallLoadRequested());
    // No network in tests → don't let google_fonts fetch; we provide the real
    // Poppins/Montserrat TTFs via FontLoader so text renders (not tofu boxes).
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  late MockPaywallBloc bloc;

  setUp(() {
    bloc = MockPaywallBloc();
    when(() => bloc.state).thenReturn(const PaywallReady(_options));
  });

  // Captures the paywall for a given tier (carousel page) and period.
  Future<void> capture(
    WidgetTester tester, {
    required bool annual,
    required int page,
    required String name,
  }) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(bloc));
    await tester.pumpAndSettle();

    if (annual) {
      await tester.tap(find.text('Anual'));
      await tester.pumpAndSettle();
    }
    // Carousel order is Free, Essencial, Pro — swipe left once per page.
    for (var i = 0; i < page; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    await expectLater(
      find.byType(PlansPage),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('free monthly', (t) =>
      capture(t, annual: false, page: 0, name: 'paywall_free_monthly'));
  testWidgets('essencial monthly', (t) =>
      capture(t, annual: false, page: 1, name: 'paywall_essencial_monthly'));
  testWidgets('essencial annual', (t) =>
      capture(t, annual: true, page: 1, name: 'paywall_essencial_annual'));
  testWidgets('pro monthly', (t) =>
      capture(t, annual: false, page: 2, name: 'paywall_pro_monthly'));
  testWidgets('pro annual', (t) =>
      capture(t, annual: true, page: 2, name: 'paywall_pro_annual'));
}
