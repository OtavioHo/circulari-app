import 'package:circulari/core/models/paginated_result.dart';
import 'package:circulari/features/items/domain/entities/item.dart';

/// One page of a list's items plus [totalValue] — the server-computed sum of
/// `user_defined_value` across the WHOLE list (all pages, same semantics as
/// the dashboard total). Lets the UI show a live total before every page has
/// been loaded. Null when the server omits the field (older backend).
class ItemsPage extends PaginatedResult<Item> {
  final double? totalValue;

  const ItemsPage({required super.data, super.nextCursor, this.totalValue});
}
