import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:circulari/features/profile/presentation/bloc/edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUsecase _updateProfile;

  EditProfileCubit(this._updateProfile) : super(const EditProfileInitial());

  Future<void> submit({required String name}) async {
    emit(const EditProfileSubmitting());
    try {
      final updatedName = await _updateProfile(name: name.trim());
      emit(EditProfileSuccess(updatedName));
    } on AppException catch (e) {
      emit(EditProfileFailure(e.message));
    }
  }
}
