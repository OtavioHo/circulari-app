import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/profile/domain/entities/plan_usage.dart';
import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';
import 'package:circulari/features/profile/domain/usecases/get_plan_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;
  late GetPlanUsecase usecase;

  setUp(() {
    repository = MockProfileRepository();
    usecase = GetPlanUsecase(repository);
  });

  test('returns user plan from repository', () async {
    const plan = UserPlan(
      plan: 'free',
      lists: PlanUsage(used: 1, max: 3),
      items: PlanUsage(used: 5, max: 50),
      aiCalls: PlanUsage(used: 0, max: 5),
    );
    when(() => repository.getPlan()).thenAnswer((_) async => plan);

    final result = await usecase();

    expect(result, plan);
    verify(() => repository.getPlan()).called(1);
  });
}
