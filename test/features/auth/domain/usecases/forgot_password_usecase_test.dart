import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/forgot_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ForgotPasswordUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = ForgotPasswordUsecase(repository);
  });

  test('forwards email to repository.forgotPassword', () async {
    when(() => repository.forgotPassword(email: any(named: 'email')))
        .thenAnswer((_) async {});

    await usecase(email: 'jane@example.com');

    verify(() => repository.forgotPassword(email: 'jane@example.com'))
        .called(1);
  });
}
