import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class CreateListUsecase {
  final ListsRepository _repository;
  const CreateListUsecase(this._repository);

  Future<String> call({
    required String name,
    String? location,
    required String colorId,
    required String iconId,
    required String pictureId,
  }) => _repository.createList(
        name: name,
        location: location,
        colorId: colorId,
        iconId: iconId,
        pictureId: pictureId,
      );
}
