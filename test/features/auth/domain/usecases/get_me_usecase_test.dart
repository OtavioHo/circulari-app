import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/get_me_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetMeUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = GetMeUsecase(repository);
  });

  test('returns user from repository.getMe', () async {
    when(() => repository.getMe()).thenAnswer((_) async => tUser);

    final result = await usecase();

    expect(result, tUser);
    verify(() => repository.getMe()).called(1);
  });
}
