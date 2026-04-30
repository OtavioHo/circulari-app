import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/domain/entities/list_picture.dart';

sealed class CreateListState {
  const CreateListState();
}

final class CreateListInitial extends CreateListState {
  const CreateListInitial();
}

final class CreateListLoading extends CreateListState {
  const CreateListLoading();
}

final class CreateListReady extends CreateListState {
  final List<ListColor> colors;
  final List<ListIcon> icons;
  final List<ListPicture> pictures;
  final ListColor selectedColor;
  final ListIcon selectedIcon;
  final ListPicture selectedPicture;
  final bool submitting;
  final String? errorMessage;

  const CreateListReady({
    required this.colors,
    required this.icons,
    required this.pictures,
    required this.selectedColor,
    required this.selectedIcon,
    required this.selectedPicture,
    this.submitting = false,
    this.errorMessage,
  });

  CreateListReady copyWith({
    ListColor? selectedColor,
    ListIcon? selectedIcon,
    ListPicture? selectedPicture,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) => CreateListReady(
        colors: colors,
        icons: icons,
        pictures: pictures,
        selectedColor: selectedColor ?? this.selectedColor,
        selectedIcon: selectedIcon ?? this.selectedIcon,
        selectedPicture: selectedPicture ?? this.selectedPicture,
        submitting: submitting ?? this.submitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

final class CreateListSuccess extends CreateListState {
  final ItemList list;
  const CreateListSuccess(this.list);
}

final class CreateListOptionsFailure extends CreateListState {
  final String message;
  const CreateListOptionsFailure(this.message);
}

/// Emitted when list creation is blocked by a plan limit.
final class CreateListQuotaExceeded extends CreateListState {
  const CreateListQuotaExceeded();
}
