import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LogoutUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LogoutUsecase(repository);
  });

  test('delegates to repository.logout', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    await usecase();

    verify(() => repository.logout()).called(1);
  });
}
