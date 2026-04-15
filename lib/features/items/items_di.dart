import 'package:get_it/get_it.dart';

import 'data/repositories/items_repository_impl.dart';
import 'data/sources/items_remote_source.dart';
import 'domain/repositories/items_repository.dart';
import 'domain/usecases/analyze_item_image_usecase.dart';
import 'domain/usecases/create_item_usecase.dart';
import 'domain/usecases/delete_item_usecase.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_items_usecase.dart';
import 'domain/usecases/update_item_usecase.dart';
import 'domain/usecases/upload_item_image_usecase.dart';
import 'presentation/bloc/ai_analysis_cubit.dart';
import 'presentation/bloc/categories_cubit.dart';
import 'presentation/bloc/items_bloc.dart';

extension ItemsDI on GetIt {
  void registerItemsFeature() {
    registerLazySingleton<ItemsRemoteSource>(() => ItemsRemoteSource(call()));
    registerLazySingleton<ItemsRepository>(() => ItemsRepositoryImpl(call()));
    registerLazySingleton(() => GetCategoriesUsecase(call()));
    registerLazySingleton(() => GetItemsUsecase(call()));
    registerLazySingleton(() => CreateItemUsecase(call()));
    registerLazySingleton(() => UpdateItemUsecase(call()));
    registerLazySingleton(() => DeleteItemUsecase(call()));
    registerLazySingleton(() => UploadItemImageUsecase(call()));
    registerLazySingleton(() => AnalyzeItemImageUsecase(call()));
    registerFactory(() => AiAnalysisCubit(call()));
    registerFactory(() => CategoriesCubit(call()));
    registerFactory(
      () => ItemsBloc(
        getItems: call(),
        createItem: call(),
        updateItem: call(),
        deleteItem: call(),
        uploadImage: call(),
      ),
    );
  }
}
