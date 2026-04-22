import 'package:get_it/get_it.dart';

import 'data/repositories/lists_repository_impl.dart';
import 'data/sources/lists_remote_source.dart';
import 'domain/repositories/lists_repository.dart';
import 'domain/usecases/create_list_usecase.dart';
import 'domain/usecases/delete_list_usecase.dart';
import 'domain/usecases/get_list_colors_usecase.dart';
import 'domain/usecases/get_list_icons_usecase.dart';
import 'domain/usecases/get_list_pictures_usecase.dart';
import 'domain/usecases/get_lists_usecase.dart';
import 'domain/usecases/rename_list_usecase.dart';
import 'presentation/bloc/lists_bloc.dart';
import 'presentation/cubit/create_list_cubit.dart';

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
    registerLazySingleton(() => RenameListUsecase(call()));
    registerFactory(
      () => ListsBloc(
        getLists: call(),
        renameList: call(),
        deleteList: call(),
      ),
    );
    registerFactory(
      () => CreateListCubit(
        getColors: call(),
        getIcons: call(),
        getPictures: call(),
        createList: call(),
      ),
    );
  }
}
