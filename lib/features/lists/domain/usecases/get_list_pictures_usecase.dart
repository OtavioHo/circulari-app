import '../entities/list_picture.dart';
import '../repositories/lists_repository.dart';

class GetListPicturesUsecase {
  final ListsRepository _repository;
  const GetListPicturesUsecase(this._repository);

  Future<List<ListPicture>> call() => _repository.getPictures();
}
