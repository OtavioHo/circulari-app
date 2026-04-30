import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/login_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUsecase(repository);
  });

  test('forwards email/password to repository.login and returns the user',
      () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => tUser);

    final result = await usecase(
      email: 'jane@example.com',
      password: 'hunter2222',
    );

    expect(result, tUser);
    verify(() => repository.login(
          email: 'jane@example.com',
          password: 'hunter2222',
        )).called(1);
  });

  test('rethrows whatever the repository throws', () {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('boom'));

    expect(
      () => usecase(email: 'a@b.com', password: '12345678'),
      throwsA(isA<Exception>()),
    );
  });
}
