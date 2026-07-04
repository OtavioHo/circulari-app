import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository _repository;

  const UpdateProfileUsecase(this._repository);

  Future<String> call({required String name}) =>
      _repository.updateProfile(name: name);
}
