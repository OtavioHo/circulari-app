sealed class ItemsEvent {
  const ItemsEvent();
}

final class ItemsLoadRequested extends ItemsEvent {
  final String listId;
  const ItemsLoadRequested(this.listId);
}

final class ItemsCreateRequested extends ItemsEvent {
  final String listId;
  final String name;
  final String? description;
  final int quantity;
  final String? categoryId;
  final String? locationId;
  final double? userDefinedValue;
  final String? imagePath;

  /// Applies the AI analysis that produced the pre-filled values — the server
  /// copies its price snapshot onto the created item.
  final String? aiAnalysisId;

  const ItemsCreateRequested({
    required this.listId,
    required this.name,
    this.description,
    this.quantity = 1,
    this.categoryId,
    this.locationId,
    this.userDefinedValue,
    this.imagePath,
    this.aiAnalysisId,
  });
}

final class ItemsUpdateRequested extends ItemsEvent {
  final String id;
  final String? name;
  final String? description;
  final int? quantity;
  final String? categoryId;
  final String? locationId;
  final double? userDefinedValue;

  const ItemsUpdateRequested(
    this.id, {
    this.name,
    this.description,
    this.quantity,
    this.categoryId,
    this.locationId,
    this.userDefinedValue,
  });
}

final class ItemsDeleteRequested extends ItemsEvent {
  final String id;
  const ItemsDeleteRequested(this.id);
}

