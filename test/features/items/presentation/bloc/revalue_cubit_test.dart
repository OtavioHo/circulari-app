import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/usecases/revalue_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/revalue_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockRevalueItemUsecase extends Mock implements RevalueItemUsecase {}

void main() {
  late MockRevalueItemUsecase revalue;

  setUp(() => revalue = MockRevalueItemUsecase());

  RevalueCubit buildCubit() => RevalueCubit(revalue);

  void stub(dynamic Function(Invocation) answerOrThrow) => when(
        () => revalue(
          any(),
          hint: any(named: 'hint'),
          parentAnalysisId: any(named: 'parentAnalysisId'),
        ),
      ).thenAnswer((i) async => answerOrThrow(i));

  test('initial state is RevalueInitial', () {
    expect(buildCubit().state, isA<RevalueInitial>());
  });

  blocTest<RevalueCubit, RevalueState>(
    'emits [Loading, Preview] and forwards item, hint and parent',
    build: buildCubit,
    setUp: () => stub((_) => tAiResult),
    act: (c) => c.revalue(
      itemId: 'item-1',
      hint: 'é um iPhone 15',
      parentAnalysisId: 'analysis-0',
    ),
    expect: () => [
      isA<RevalueLoading>(),
      isA<RevaluePreview>().having((s) => s.result, 'result', tAiResult),
    ],
    verify: (_) => verify(
      () => revalue('item-1', hint: 'é um iPhone 15', parentAnalysisId: 'analysis-0'),
    ).called(1),
  );

  blocTest<RevalueCubit, RevalueState>(
    'emits QuotaExceeded on PlanLimitException',
    build: buildCubit,
    setUp: () => stub((_) => throw const PlanLimitException()),
    act: (c) => c.revalue(itemId: 'item-1', hint: 'x'),
    expect: () => [isA<RevalueLoading>(), isA<RevalueQuotaExceeded>()],
  );

  blocTest<RevalueCubit, RevalueState>(
    'maps a 429 to the wait message',
    build: buildCubit,
    setUp: () => stub((_) => throw const RateLimitException()),
    act: (c) => c.revalue(itemId: 'item-1', hint: 'x'),
    expect: () => [
      isA<RevalueLoading>(),
      isA<RevalueFailure>().having(
        (s) => s.message,
        'message',
        'Muitas análises seguidas. Aguarde um instante.',
      ),
    ],
  );

  blocTest<RevalueCubit, RevalueState>(
    'surfaces e.message on generic AppException',
    build: buildCubit,
    setUp: () => stub((_) => throw const ServerException('boom')),
    act: (c) => c.revalue(itemId: 'item-1', hint: 'x'),
    expect: () => [
      isA<RevalueLoading>(),
      isA<RevalueFailure>().having((s) => s.message, 'message', 'boom'),
    ],
  );

  blocTest<RevalueCubit, RevalueState>(
    'reset returns to the hint input (Descartar keeps the analysis counted)',
    build: buildCubit,
    setUp: () => stub((_) => tAiResult),
    act: (c) async {
      await c.revalue(itemId: 'item-1', hint: 'x');
      c.reset();
    },
    skip: 2,
    expect: () => [isA<RevalueInitial>()],
  );

  blocTest<RevalueCubit, RevalueState>(
    'chains the second correction to the analysis just produced',
    build: buildCubit,
    setUp: () => stub((_) => const AiAnalysisResult(
          analysisId: 'A1',
          name: 'iPhone 15',
          description: 'd',
          priceMin: 3000,
          priceMax: 3800,
        )),
    act: (c) async {
      await c.revalue(itemId: 'item-1', hint: 'hint 1', parentAnalysisId: 'A0');
      c.reset(); // Descartar must not reset the chain
      await c.revalue(itemId: 'item-1', hint: 'hint 2', parentAnalysisId: 'A0');
    },
    verify: (_) {
      verify(() => revalue('item-1', hint: 'hint 1', parentAnalysisId: 'A0')).called(1);
      // The second correction refines the analysis just produced, not the
      // item's original one (whose retry is already spent server-side).
      verify(() => revalue('item-1', hint: 'hint 2', parentAnalysisId: 'A1')).called(1);
    },
  );

  test('does not throw when the sheet closes mid-request (emit after close)', () async {
    stub((_) => Future.delayed(const Duration(milliseconds: 50), () => tAiResult));
    final cubit = buildCubit();
    final pending = cubit.revalue(itemId: 'item-1', hint: 'x');
    await cubit.close();
    // The late emit must be swallowed, not thrown as StateError.
    await pending;
  });

  blocTest<RevalueCubit, RevalueState>(
    'ignores a second revalue while one is in flight',
    build: buildCubit,
    setUp: () => stub((_) => Future.delayed(
          const Duration(milliseconds: 50),
          () => tAiResult,
        )),
    act: (c) async {
      final first = c.revalue(itemId: 'item-1', hint: 'x');
      await c.revalue(itemId: 'item-1', hint: 'y'); // ignored
      await first;
    },
    expect: () => [isA<RevalueLoading>(), isA<RevaluePreview>()],
    verify: (_) => verify(
      () => revalue(
        any(),
        hint: any(named: 'hint'),
        parentAnalysisId: any(named: 'parentAnalysisId'),
      ),
    ).called(1),
  );
}
