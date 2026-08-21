import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/domain/entities/list_color.dart';
import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/domain/entities/list_picture.dart';
import 'package:circulari/features/lists/domain/usecases/create_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_colors_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_icons_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_pictures_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/update_list_usecase.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_state.dart';

/// Drives the list form in both modes: create ([initial] == null) and edit.
class CreateListCubit extends Cubit<CreateListState> {
  final GetListColorsUsecase _getColors;
  final GetListIconsUsecase _getIcons;
  final GetListPicturesUsecase _getPictures;
  final CreateListUsecase _createList;
  final UpdateListUsecase _updateList;
  final DeleteListUsecase _deleteList;
  final ItemList? initial;

  CreateListCubit({
    required GetListColorsUsecase getColors,
    required GetListIconsUsecase getIcons,
    required GetListPicturesUsecase getPictures,
    required CreateListUsecase createList,
    required UpdateListUsecase updateList,
    required DeleteListUsecase deleteList,
    this.initial,
  })  : _getColors = getColors,
        _getIcons = getIcons,
        _getPictures = getPictures,
        _createList = createList,
        _updateList = updateList,
        _deleteList = deleteList,
        super(const CreateListInitial());

  bool get isEditing => initial != null;

  Future<void> loadOptions() async {
    emit(const CreateListLoading());
    try {
      final results = await Future.wait([
        _getColors(),
        _getIcons(),
        _getPictures(),
      ]);
      // The data layer returns model-typed lists (e.g. List<ListColorModel>).
      // cast() rebinds the element type so firstWhere's `orElse` closure
      // (typed against the entity) is accepted at runtime — a plain downcast
      // keeps the covariant runtime type and throws inside firstWhere.
      final colors = (results[0] as List).cast<ListColor>();
      final icons = (results[1] as List).cast<ListIcon>();
      final pictures = (results[2] as List).cast<ListPicture>();

      if (colors.isEmpty || icons.isEmpty || pictures.isEmpty) {
        emit(const CreateListOptionsFailure('No options available from server.'));
        return;
      }

      emit(CreateListReady(
        colors: colors,
        icons: icons,
        pictures: pictures,
        selectedColor: colors.firstWhere(
          (c) => c.hexCode == initial?.color.hexCode,
          orElse: () => colors.first,
        ),
        selectedIcon: icons.firstWhere(
          (i) => i.slug == initial?.icon.slug,
          orElse: () => icons.first,
        ),
        selectedPicture: pictures.firstWhere(
          (p) => p.slug == initial?.picture.slug,
          orElse: () => pictures.first,
        ),
      ));
    } on AppException catch (e) {
      emit(CreateListOptionsFailure(e.message));
    }
  }

  void selectColor(ListColor color) {
    final ready = _requireReady();
    if (ready == null) return;
    emit(ready.copyWith(selectedColor: color, clearError: true));
  }

  void selectIcon(ListIcon icon) {
    final ready = _requireReady();
    if (ready == null) return;
    emit(ready.copyWith(selectedIcon: icon, clearError: true));
  }

  void selectPicture(ListPicture picture) {
    final ready = _requireReady();
    if (ready == null) return;
    emit(ready.copyWith(selectedPicture: picture, clearError: true));
  }

  Future<void> submit({
    required String name,
    String? location,
  }) async {
    final ready = _requireReady();
    if (ready == null) return;

    emit(ready.copyWith(submitting: true, clearError: true));
    final cleanLocation =
        location?.trim().isEmpty == true ? null : location?.trim();
    try {
      if (initial case final list?) {
        await _updateList(
          list.id,
          name: name,
          location: cleanLocation,
          colorId: ready.selectedColor.hexCode,
          iconId: ready.selectedIcon.slug,
          pictureId: ready.selectedPicture.slug,
        );
        emit(CreateListSuccess(list.copyWith(
          name: name,
          location: cleanLocation,
          color: ready.selectedColor,
          icon: ready.selectedIcon,
          picture: ready.selectedPicture,
        )));
        return;
      }
      final id = await _createList(
        name: name,
        location: cleanLocation,
        colorId: ready.selectedColor.hexCode,
        iconId: ready.selectedIcon.slug,
        pictureId: ready.selectedPicture.slug,
      );
      emit(CreateListSuccess(ItemList(
        id: id,
        name: name,
        location: cleanLocation,
        color: ready.selectedColor,
        icon: ready.selectedIcon,
        picture: ready.selectedPicture,
        itemCount: 0,
        totalValue: 0,
        createdAt: DateTime.now(),
      )));
    } on PlanLimitException {
      _emitQuotaExceeded(ready);
    } on TierRequiredException {
      _emitQuotaExceeded(ready);
    } on AppException catch (e) {
      emit(ready.copyWith(submitting: false, errorMessage: e.message));
    }
  }

  Future<void> delete() async {
    final list = initial;
    final ready = _requireReady();
    if (list == null || ready == null) return;

    emit(ready.copyWith(submitting: true, clearError: true));
    try {
      await _deleteList(list.id);
      emit(const CreateListDeleted());
    } on AppException catch (e) {
      emit(ready.copyWith(submitting: false, errorMessage: e.message));
    }
  }

  /// [CreateListQuotaExceeded] is a one-shot signal for the paywall listener;
  /// the form state is restored immediately after so the user keeps their
  /// input (and the page isn't left blank) once the paywall sheet closes.
  void _emitQuotaExceeded(CreateListReady ready) {
    emit(const CreateListQuotaExceeded());
    emit(ready.copyWith(submitting: false));
  }

  CreateListReady? _requireReady() =>
      state is CreateListReady ? state as CreateListReady : null;
}
