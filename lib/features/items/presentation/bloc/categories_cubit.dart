import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

sealed class CategoriesState {
  const CategoriesState();
}

final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesSuccess extends CategoriesState {
  final List<Category> categories;
  const CategoriesSuccess(this.categories);
}

final class CategoriesFailure extends CategoriesState {
  final String message;
  const CategoriesFailure(this.message);
}

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUsecase _getCategories;

  CategoriesCubit(this._getCategories) : super(const CategoriesInitial());

  Future<void> load() async {
    emit(const CategoriesLoading());
    try {
      final categories = await _getCategories();
      emit(CategoriesSuccess(categories));
    } on AppException catch (e) {
      emit(CategoriesFailure(e.message));
    }
  }
}
