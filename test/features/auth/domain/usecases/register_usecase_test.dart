import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/register_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RegisterUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterUsecase(repository);
  });

  test('forwards args to repository.register and returns the user', () async {
    when(() => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        )).thenAnswer((_) async => tUser);

    final result = await usecase(
      email: 'jane@example.com',
      password: 'hunter2222',
      name: 'Jane Doe',
    );

    expect(result, tUser);
    verify(() => repository.register(
          email: 'jane@example.com',
          password: 'hunter2222',
          name: 'Jane Doe',
        )).called(1);
  });
}
