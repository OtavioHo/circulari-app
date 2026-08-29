import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/usecases/share_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/share_item_cubit.dart';

class MockShareItemUsecase extends Mock implements ShareItemUsecase {}

void main() {
  late MockShareItemUsecase shareItem;

  setUp(() => shareItem = MockShareItemUsecase());

  ShareItemCubit buildCubit() => ShareItemCubit(shareItem);

  test('initial state is ShareItemInitial', () {
    expect(buildCubit().state, isA<ShareItemInitial>());
  });

  blocTest<ShareItemCubit, ShareItemState>(
    'emits [Loading, Ready] with the URL and forwards the item id',
    build: buildCubit,
    setUp: () => when(() => shareItem(any()))
        .thenAnswer((_) async => 'https://share.test/i/tok-abc'),
    act: (c) => c.share('item-1'),
    expect: () => [
      isA<ShareItemLoading>(),
      isA<ShareItemReady>()
          .having((s) => s.url, 'url', 'https://share.test/i/tok-abc'),
    ],
    verify: (_) => verify(() => shareItem('item-1')).called(1),
  );

  blocTest<ShareItemCubit, ShareItemState>(
    'surfaces the message on failure without losing the page',
    build: buildCubit,
    setUp: () => when(() => shareItem(any()))
        .thenThrow(const ServerException('Sem conexão')),
    act: (c) => c.share('item-1'),
    expect: () => [
      isA<ShareItemLoading>(),
      isA<ShareItemFailure>().having((s) => s.message, 'message', 'Sem conexão'),
    ],
  );

  // Two taps landing before the first request resolves must not open two
  // share sheets.
  blocTest<ShareItemCubit, ShareItemState>(
    'ignores a second share while one is already in flight',
    build: buildCubit,
    setUp: () => when(() => shareItem(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 'https://share.test/i/tok-abc';
    }),
    act: (c) {
      c.share('item-1');
      c.share('item-1');
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [isA<ShareItemLoading>(), isA<ShareItemReady>()],
    verify: (_) => verify(() => shareItem('item-1')).called(1),
  );

  // The sheet is opened from a listener reacting to Ready; without resetting,
  // a second tap would re-emit the same state and bloc would dedupe it.
  blocTest<ShareItemCubit, ShareItemState>(
    'returns to idle after reset so a repeat share still fires',
    build: buildCubit,
    setUp: () => when(() => shareItem(any()))
        .thenAnswer((_) async => 'https://share.test/i/tok-abc'),
    act: (c) async {
      await c.share('item-1');
      c.reset();
      await c.share('item-1');
    },
    expect: () => [
      isA<ShareItemLoading>(),
      isA<ShareItemReady>(),
      isA<ShareItemInitial>(),
      isA<ShareItemLoading>(),
      isA<ShareItemReady>(),
    ],
  );
}
