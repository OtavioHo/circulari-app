class ItemList {
  final String id;
  final String name;
  final int itemCount;
  final double totalValue;
  final DateTime createdAt;

  const ItemList({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.totalValue,
    required this.createdAt,
  });
}
