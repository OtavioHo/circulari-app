import 'package:get_it/get_it.dart';

import 'package:circulari/features/items/data/repositories/items_repository_impl.dart';
import 'package:circulari/features/items/data/sources/items_remote_source.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/analyze_item_image_usecase.dart';
import 'package:circulari/features/items/domain/usecases/create_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/get_categories_usecase.dart';
import 'package:circulari/features/items/domain/usecases/get_items_usecase.dart';
import 'package:circulari/features/items/domain/usecases/search_items_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/ai_analysis_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/categories_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_bloc.dart';

extension ItemsDI on GetIt {
  void registerItemsFeature() {
    registerLazySingleton<ItemsRemoteSource>(() => ItemsRemoteSource(call()));
    registerLazySingleton<ItemsRepository>(() => ItemsRepositoryImpl(call()));
    registerLazySingleton(() => GetCategoriesUsecase(call()));
    registerLazySingleton(() => GetItemsUsecase(call()));
    registerLazySingleton(() => CreateItemUsecase(call()));
    registerLazySingleton(() => UpdateItemUsecase(call()));
    registerLazySingleton(() => DeleteItemUsecase(call()));
    registerLazySingleton(() => AnalyzeItemImageUsecase(call()));
    registerLazySingleton(() => SearchItemsUsecase(call()));
    registerFactory(() => AiAnalysisCubit(call()));
    registerFactory(() => SearchItemsBloc(searchItems: call()));
    registerFactory(() => CategoriesCubit(call()));
    registerFactory(
      () => ItemsBloc(
        getItems: call(),
        createItem: call(),
        updateItem: call(),
        deleteItem: call(),
      ),
    );
  }
}
