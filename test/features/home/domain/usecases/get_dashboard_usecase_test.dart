import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/home/domain/entities/dashboard_summary.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/home/domain/usecases/get_dashboard_usecase.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository repository;
  late GetDashboardUsecase usecase;

  setUp(() {
    repository = MockHomeRepository();
    usecase = GetDashboardUsecase(repository);
  });

  test('returns dashboard summary from repository', () async {
    const summary =
        DashboardSummary(listCount: 2, itemCount: 7, totalValue: 99.5);
    when(() => repository.getDashboard()).thenAnswer((_) async => summary);

    final result = await usecase();

    expect(result, summary);
    verify(() => repository.getDashboard()).called(1);
  });
}
