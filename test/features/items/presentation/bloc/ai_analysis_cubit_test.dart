import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/usecases/analyze_item_image_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/ai_analysis_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockAnalyzeItemImageUsecase extends Mock
    implements AnalyzeItemImageUsecase {}

void main() {
  late MockAnalyzeItemImageUsecase analyze;

  setUp(() => analyze = MockAnalyzeItemImageUsecase());

  AiAnalysisCubit buildCubit() => AiAnalysisCubit(analyze);

  test('initial state is AiAnalysisInitial', () {
    expect(buildCubit().state, isA<AiAnalysisInitial>());
  });

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'emits [Loading, Success] on success',
    build: buildCubit,
    setUp: () =>
        when(() => analyze(any())).thenAnswer((_) async => tAiResult),
    act: (c) => c.analyze('/tmp/x.jpg'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisSuccess>().having((s) => s.result, 'result', tAiResult),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'emits QuotaExceeded on PlanLimitException',
    build: buildCubit,
    setUp: () => when(() => analyze(any()))
        .thenThrow(const PlanLimitException()),
    act: (c) => c.analyze('/tmp/x.jpg'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisQuotaExceeded>(),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'emits QuotaExceeded on TierRequiredException',
    build: buildCubit,
    setUp: () => when(() => analyze(any()))
        .thenThrow(const TierRequiredException()),
    act: (c) => c.analyze('/tmp/x.jpg'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisQuotaExceeded>(),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'emits Failure with message on generic AppException',
    build: buildCubit,
    setUp: () => when(() => analyze(any()))
        .thenThrow(const ServerException('boom')),
    act: (c) => c.analyze('/tmp/x.jpg'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisFailure>().having((s) => s.message, 'message', 'boom'),
    ],
  );

  group('refine', () {
    const tRefined = AiAnalysisResult(
      analysisId: 'a2',
      name: 'iPhone 15',
      description: 'Refinado.',
      priceMin: 3000,
      priceMax: 3800,
    );

    void stubAnalyzeOk() =>
        when(() => analyze(any())).thenAnswer((_) async => tAiResult);
    // `that: isNotNull` keeps this stub from also swallowing the initial
    // analyze() call (which passes no hint) — mocktail picks the most recently
    // registered matching stub.
    void stubRefine(dynamic Function(Invocation) answerOrThrow) => when(
          () => analyze(
            any(),
            hint: any(named: 'hint', that: isNotNull),
            parentAnalysisId: any(named: 'parentAnalysisId'),
          ),
        ).thenAnswer((i) async => answerOrThrow(i));

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'emits [Refining(previous), RefineSuccess] and forwards the hint',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => tRefined);
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        await c.refine('é um iPhone 15');
      },
      skip: 2, // Loading + initial Success
      expect: () => [
        isA<AiAnalysisRefining>().having((s) => s.previous, 'previous', tAiResult),
        isA<AiAnalysisRefineSuccess>()
            .having((s) => s.result, 'result', tRefined)
            .having((s) => s.previous, 'previous', tAiResult),
      ],
      verify: (_) => verify(
        () => analyze(
          '/tmp/x.jpg',
          hint: 'é um iPhone 15',
          parentAnalysisId: tAiResult.analysisId,
        ),
      ).called(1),
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'is a no-op without a prior successful analysis',
      build: buildCubit,
      act: (c) => c.refine('é um iPhone 15'),
      expect: () => const [],
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'ignores a second refine while one is in flight (double chip tap)',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => Future<AiAnalysisResult>.delayed(
              const Duration(milliseconds: 50),
              () => tRefined,
            ));
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        final first = c.refine('é um iPhone 15');
        await c.refine('é um iPhone 13'); // ignored: already refining
        await first;
      },
      skip: 2,
      expect: () => [
        isA<AiAnalysisRefining>(),
        isA<AiAnalysisRefineSuccess>(),
      ],
      verify: (_) => verify(
        () => analyze(
          any(),
          hint: any(named: 'hint', that: isNotNull),
          parentAnalysisId: any(named: 'parentAnalysisId'),
        ),
      ).called(1),
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'keeps the previous result and surfaces e.message on failure',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => throw const ServerException('boom'));
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        await c.refine('é um iPhone 15');
      },
      skip: 2,
      expect: () => [
        isA<AiAnalysisRefining>(),
        isA<AiAnalysisRefineFailure>()
            .having((s) => s.previous, 'previous', tAiResult)
            .having((s) => s.message, 'message', 'boom'),
      ],
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'maps a 429 to the wait message',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => throw const RateLimitException());
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        await c.refine('é um iPhone 15');
      },
      skip: 2,
      expect: () => [
        isA<AiAnalysisRefining>(),
        isA<AiAnalysisRefineFailure>().having(
          (s) => s.message,
          'message',
          'Muitas análises seguidas. Aguarde um instante.',
        ),
      ],
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'surfaces the paywall then restores the previous result on quota',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => throw const PlanLimitException());
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        await c.refine('é um iPhone 15');
      },
      skip: 2,
      expect: () => [
        isA<AiAnalysisRefining>(),
        isA<AiAnalysisQuotaExceeded>(),
        // Restored, not Success: the form must not re-fill from it.
        isA<AiAnalysisRestored>().having((s) => s.result, 'result', tAiResult),
      ],
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'undo restores the pre-refine analysis as Restored',
      build: buildCubit,
      setUp: () {
        stubAnalyzeOk();
        stubRefine((_) => tRefined);
      },
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        await c.refine('é um iPhone 15');
        c.undo();
      },
      skip: 4, // Loading, Success, Refining, RefineSuccess
      expect: () => [
        isA<AiAnalysisRestored>().having((s) => s.result, 'result', tAiResult),
      ],
    );

    blocTest<AiAnalysisCubit, AiAnalysisState>(
      'undo is a no-op without a refine',
      build: buildCubit,
      setUp: stubAnalyzeOk,
      act: (c) async {
        await c.analyze('/tmp/x.jpg');
        c.undo();
      },
      skip: 2,
      expect: () => const [],
    );
  });
}
