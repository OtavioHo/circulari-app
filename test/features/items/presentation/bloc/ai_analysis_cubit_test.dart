import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
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
}
