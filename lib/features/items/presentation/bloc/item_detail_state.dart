import '../../domain/entities/item.dart';

sealed class ItemDetailState {
  const ItemDetailState();
}

final class ItemDetailInitial extends ItemDetailState {
  final Item item;
  const ItemDetailInitial(this.item);
}

final class ItemDetailLoading extends ItemDetailState {
  final Item item;
  const ItemDetailLoading(this.item);
}

final class ItemDetailSuccess extends ItemDetailState {
  final Item item;
  const ItemDetailSuccess(this.item);
}

final class ItemDetailFailure extends ItemDetailState {
  final Item item;
  final String message;
  const ItemDetailFailure(this.item, this.message);
}

final class ItemDetailDeleted extends ItemDetailState {
  const ItemDetailDeleted();
}
