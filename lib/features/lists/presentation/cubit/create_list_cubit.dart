import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/list_color.dart';
import '../../domain/entities/list_icon.dart';
import '../../domain/entities/list_picture.dart';
import '../../domain/usecases/create_list_usecase.dart';
import '../../domain/usecases/get_list_colors_usecase.dart';
import '../../domain/usecases/get_list_icons_usecase.dart';
import '../../domain/usecases/get_list_pictures_usecase.dart';
import 'create_list_state.dart';

class CreateListCubit extends Cubit<CreateListState> {
  final GetListColorsUsecase _getColors;
  final GetListIconsUsecase _getIcons;
  final GetListPicturesUsecase _getPictures;
  final CreateListUsecase _createList;

  CreateListCubit({
    required GetListColorsUsecase getColors,
    required GetListIconsUsecase getIcons,
    required GetListPicturesUsecase getPictures,
    required CreateListUsecase createList,
  })  : _getColors = getColors,
        _getIcons = getIcons,
        _getPictures = getPictures,
        _createList = createList,
        super(const CreateListInitial());

  Future<void> loadOptions() async {
    emit(const CreateListLoading());
    try {
      final results = await Future.wait([
        _getColors(),
        _getIcons(),
        _getPictures(),
      ]);
      final colors = results[0] as List<ListColor>;
      final icons = results[1] as List<ListIcon>;
      final pictures = results[2] as List<ListPicture>;

      if (colors.isEmpty || icons.isEmpty || pictures.isEmpty) {
        emit(const CreateListOptionsFailure('No options available from server.'));
        return;
      }

      emit(CreateListReady(
        colors: colors,
        icons: icons,
        pictures: pictures,
        selectedColor: colors.first,
        selectedIcon: icons.first,
        selectedPicture: pictures.first,
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
    try {
      await _createList(
        name: name,
        location: location?.trim().isEmpty == true ? null : location?.trim(),
        colorId: ready.selectedColor.hexCode,
        iconId: ready.selectedIcon.slug,
        pictureId: ready.selectedPicture.slug,
      );
      emit(const CreateListSuccess());
    } on PlanLimitException {
      emit(const CreateListQuotaExceeded());
    } on TierRequiredException {
      emit(const CreateListQuotaExceeded());
    } on AppException catch (e) {
      emit(ready.copyWith(submitting: false, errorMessage: e.message));
    }
  }

  CreateListReady? _requireReady() =>
      state is CreateListReady ? state as CreateListReady : null;
}
