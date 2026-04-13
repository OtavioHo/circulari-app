import 'package:get_it/get_it.dart';

import 'data/repositories/lists_repository_impl.dart';
import 'data/sources/lists_remote_source.dart';
import 'domain/repositories/lists_repository.dart';
import 'domain/usecases/create_list_usecase.dart';
import 'domain/usecases/delete_list_usecase.dart';
import 'domain/usecases/get_lists_usecase.dart';
import 'domain/usecases/rename_list_usecase.dart';
import 'presentation/bloc/lists_bloc.dart';

extension ListsDI on GetIt {
  void registerListsFeature() {
    registerLazySingleton<ListsRemoteSource>(() => ListsRemoteSource(call()));
    registerLazySingleton<ListsRepository>(() => ListsRepositoryImpl(call()));
    registerLazySingleton(() => GetListsUsecase(call()));
    registerLazySingleton(() => CreateListUsecase(call()));
    registerLazySingleton(() => DeleteListUsecase(call()));
    registerLazySingleton(() => RenameListUsecase(call()));
    registerFactory(
      () => ListsBloc(
        getLists: call(),
        createList: call(),
        deleteList: call(),
        renameList: call(),
      ),
    );
  }
}
