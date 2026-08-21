import 'package:get_it/get_it.dart';

import 'package:circulari/features/lists/data/repositories/lists_repository_impl.dart';
import 'package:circulari/features/lists/data/sources/lists_remote_source.dart';
import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/create_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_colors_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_icons_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_pictures_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/get_lists_usecase.dart';
import 'package:circulari/features/lists/domain/usecases/update_list_usecase.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_cubit.dart';

extension ListsDI on GetIt {
  void registerListsFeature() {
    registerLazySingleton<ListsRemoteSource>(() => ListsRemoteSource(call()));
    registerLazySingleton<ListsRepository>(() => ListsRepositoryImpl(call()));
    registerLazySingleton(() => GetListsUsecase(call()));
    registerLazySingleton(() => GetListColorsUsecase(call()));
    registerLazySingleton(() => GetListIconsUsecase(call()));
    registerLazySingleton(() => GetListPicturesUsecase(call()));
    registerLazySingleton(() => CreateListUsecase(call()));
    registerLazySingleton(() => DeleteListUsecase(call()));
    registerLazySingleton(() => UpdateListUsecase(call()));
    registerFactory(
      () => ListsBloc(
        getLists: call(),
        deleteList: call(),
      ),
    );
    // param1 carries the list being edited; null means create mode.
    registerFactoryParam<CreateListCubit, ItemList?, void>(
      (initial, _) => CreateListCubit(
        getColors: call(),
        getIcons: call(),
        getPictures: call(),
        createList: call(),
        updateList: call(),
        deleteList: call(),
        initial: initial,
      ),
    );
  }
}
