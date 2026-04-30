import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class GetCategoriesUsecase {
  final ItemsRepository _repository;
  const GetCategoriesUsecase(this._repository);

  Future<List<Category>> call() => _repository.getCategories();
}
