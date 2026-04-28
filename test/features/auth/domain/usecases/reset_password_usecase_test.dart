import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ResetPasswordUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = ResetPasswordUsecase(repository);
  });

  test('forwards args to repository.resetPassword', () async {
    when(() => repository.resetPassword(
          email: any(named: 'email'),
          resetToken: any(named: 'resetToken'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async {});

    await usecase(
      email: 'jane@example.com',
      resetToken: 'tok-123',
      newPassword: 'newpass!!',
    );

    verify(() => repository.resetPassword(
          email: 'jane@example.com',
          resetToken: 'tok-123',
          newPassword: 'newpass!!',
        )).called(1);
  });
}
