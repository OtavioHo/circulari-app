import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class UpdateListUsecase {
  final ListsRepository _repository;
  const UpdateListUsecase(this._repository);

  Future<void> call(
    String id, {
    required String name,
    String? location,
    String? colorId,
    String? iconId,
    String? pictureId,
  }) => _repository.updateList(
        id,
        name: name,
        location: location,
        colorId: colorId,
        iconId: iconId,
        pictureId: pictureId,
      );
}
