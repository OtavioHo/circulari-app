import 'package:circulari/features/lists/domain/entities/list_picture.dart';
import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';

class GetListPicturesUsecase {
  final ListsRepository _repository;
  const GetListPicturesUsecase(this._repository);

  Future<List<ListPicture>> call() => _repository.getPictures();
}
