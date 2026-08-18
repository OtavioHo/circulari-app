sealed class ItemDetailEvent {
  const ItemDetailEvent();
}

final class ItemDetailUpdateRequested extends ItemDetailEvent {
  final String id;
  final String? name;
  final String? description;
  final int? quantity;
  final String? categoryId;
  final double? userDefinedValue;

  /// Applies a re-analysis to the item — the server copies its price snapshot.
  final String? aiAnalysisId;

  const ItemDetailUpdateRequested(
    this.id, {
    this.name,
    this.description,
    this.quantity,
    this.categoryId,
    this.userDefinedValue,
    this.aiAnalysisId,
  });
}

final class ItemDetailDeleteRequested extends ItemDetailEvent {
  final String id;
  const ItemDetailDeleteRequested(this.id);
}
