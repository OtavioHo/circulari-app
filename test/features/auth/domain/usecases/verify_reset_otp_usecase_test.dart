import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/verify_reset_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late VerifyResetOtpUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = VerifyResetOtpUsecase(repository);
  });

  test('forwards email/otp and returns reset token', () async {
    when(() => repository.verifyResetOtp(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
        )).thenAnswer((_) async => 'reset-token-abc');

    final result = await usecase(email: 'jane@example.com', otp: '123456');

    expect(result, 'reset-token-abc');
    verify(() => repository.verifyResetOtp(
          email: 'jane@example.com',
          otp: '123456',
        )).called(1);
  });
}
