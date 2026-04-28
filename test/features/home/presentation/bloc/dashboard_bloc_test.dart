import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/home/domain/entities/dashboard_summary.dart';
import 'package:app/features/home/domain/usecases/get_dashboard_usecase.dart';
import 'package:app/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:app/features/home/presentation/bloc/dashboard_event.dart';
import 'package:app/features/home/presentation/bloc/dashboard_state.dart';

class MockGetDashboardUsecase extends Mock implements GetDashboardUsecase {}

const _tSummary = DashboardSummary(
  listCount: 3,
  itemCount: 42,
  totalValue: 1234.5,
);

void main() {
  late MockGetDashboardUsecase getDashboard;

  setUp(() => getDashboard = MockGetDashboardUsecase());

  DashboardBloc buildBloc() => DashboardBloc(getDashboard);

  test('initial state is DashboardInitial', () {
    expect(buildBloc().state, isA<DashboardInitial>());
  });

  blocTest<DashboardBloc, DashboardState>(
    'emits [Loading, Success] with the returned summary',
    build: buildBloc,
    setUp: () =>
        when(() => getDashboard()).thenAnswer((_) async => _tSummary),
    act: (b) => b.add(const DashboardLoadRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardSuccess>().having((s) => s.summary, 'summary', _tSummary),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits [Loading, Failure] on AppException',
    build: buildBloc,
    setUp: () =>
        when(() => getDashboard()).thenThrow(const ServerException('boom')),
    act: (b) => b.add(const DashboardLoadRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardFailure>().having((s) => s.message, 'message', 'boom'),
    ],
  );
}
