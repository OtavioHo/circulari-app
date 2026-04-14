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
  final String? locationId;
  final double? userDefinedValue;
  final String? imagePath;

  const ItemsCreateRequested({
    required this.listId,
    required this.name,
    this.description,
    this.quantity = 1,
    this.locationId,
    this.userDefinedValue,
    this.imagePath,
  });
}

final class ItemsUpdateRequested extends ItemsEvent {
  final String id;
  final String? name;
  final String? description;
  final int? quantity;
  final String? locationId;
  final double? userDefinedValue;

  const ItemsUpdateRequested(
    this.id, {
    this.name,
    this.description,
    this.quantity,
    this.locationId,
    this.userDefinedValue,
  });
}

final class ItemsDeleteRequested extends ItemsEvent {
  final String id;
  const ItemsDeleteRequested(this.id);
}

final class ItemsImageUploadRequested extends ItemsEvent {
  final String itemId;
  final String imagePath;
  const ItemsImageUploadRequested(this.itemId, this.imagePath);
}
