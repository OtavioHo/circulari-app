import 'package:circulari/core/models/paginated_result.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class SearchItemsUsecase {
  final ItemsRepository _repository;
  const SearchItemsUsecase(this._repository);

  Future<PaginatedResult<Item>> call({
    String? search,
    String? cursor,
    int? limit,
  }) =>
      _repository.searchItems(search: search, cursor: cursor, limit: limit);
}
