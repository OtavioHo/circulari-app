import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/profile/domain/entities/plan_usage.dart';
import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/domain/usecases/get_plan_usecase.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_bloc.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_event.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_state.dart';

class MockGetPlanUsecase extends Mock implements GetPlanUsecase {}

const _tPlan = UserPlan(
  plan: 'free',
  lists: PlanUsage(used: 1, max: 3),
  items: PlanUsage(used: 5, max: 50),
  aiCalls: PlanUsage(used: 0, max: 10),
);

void main() {
  late MockGetPlanUsecase getPlan;

  setUp(() => getPlan = MockGetPlanUsecase());

  PlanBloc buildBloc() => PlanBloc(getPlan);

  test('initial state is PlanInitial', () {
    expect(buildBloc().state, isA<PlanInitial>());
  });

  blocTest<PlanBloc, PlanState>(
    'emits [Loading, Success] with the returned plan',
    build: buildBloc,
    setUp: () => when(() => getPlan()).thenAnswer((_) async => _tPlan),
    act: (b) => b.add(const PlanLoadRequested()),
    expect: () => [
      isA<PlanLoading>(),
      isA<PlanSuccess>().having((s) => s.plan, 'plan', _tPlan),
    ],
  );

  blocTest<PlanBloc, PlanState>(
    'emits [Loading, Failure] on AppException',
    build: buildBloc,
    setUp: () => when(() => getPlan()).thenThrow(const NetworkException()),
    act: (b) => b.add(const PlanLoadRequested()),
    expect: () => [
      isA<PlanLoading>(),
      isA<PlanFailure>().having(
        (s) => s.message,
        'message',
        'No internet connection.',
      ),
    ],
  );
}
