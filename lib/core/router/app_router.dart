import 'package:app/features/add/presentation/pages/add_page.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/items/presentation/pages/add_item_form_page.dart';
import 'package:app/features/items/presentation/pages/add_item_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_state_notifier.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/items/domain/entities/item.dart';
import '../../features/items/domain/usecases/delete_item_usecase.dart';
import '../../features/items/domain/usecases/update_item_usecase.dart';
import '../../features/items/presentation/bloc/ai_analysis_cubit.dart';
import '../../features/items/presentation/bloc/categories_cubit.dart';
import '../../features/items/presentation/bloc/item_detail_bloc.dart';
import '../../features/items/presentation/bloc/items_bloc.dart';
import '../../features/items/presentation/bloc/items_event.dart';
import '../../features/items/presentation/bloc/search_items_bloc.dart';
import '../../features/items/presentation/bloc/search_items_event.dart';
import '../../features/items/presentation/pages/item_detail_page.dart';
import '../../features/items/presentation/pages/items_page.dart';
import '../../features/items/presentation/pages/select_list_page.dart';
import '../../features/home/presentation/bloc/dashboard_bloc.dart';
import '../../features/home/presentation/bloc/dashboard_event.dart';
import '../../features/lists/presentation/bloc/lists_bloc.dart';
import '../../features/lists/presentation/bloc/lists_event.dart';
import '../../features/lists/presentation/cubit/create_list_cubit.dart';
import '../../features/lists/presentation/pages/create_list_page.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'scaffold_with_navbar.dart';

final appRouter = GoRouter(
  initialLocation: '/lists',
  refreshListenable: sl<AuthStateNotifier>(),
  redirect: (context, state) {
    final isAuthenticated = sl<AuthStateNotifier>().isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) return '/lists';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) =>
          BlocProvider(create: (_) => sl<AuthBloc>(), child: const LoginPage()),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    sl<DashboardBloc>()..add(const DashboardLoadRequested()),
              ),
              BlocProvider(
                create: (_) => sl<ListsBloc>()..add(const ListsLoadRequested()),
              ),
              BlocProvider(
                create: (_) => sl<SearchItemsBloc>()
                  ..add(const SearchItemsLoadRequested()),
              ),
            ],
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/lists',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<AuthBloc>()),
              BlocProvider(
                create: (_) => sl<ListsBloc>()..add(const ListsLoadRequested()),
              ),
            ],
            child: const ListsPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(path: '/add', builder: (context, state) => const AddPage()),
      ],
    ),
    GoRoute(
      path: '/lists/create',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CreateListCubit>()..loadOptions(),
        child: const CreateListPage(),
      ),
    ),
    //TODO: Refactor to call /details and fetch the list name instead of passing it as a query parameter
    GoRoute(
      path: '/lists/:id/items',
      builder: (context, state) {
        final listId = state.pathParameters['id']!;
        final listName = state.uri.queryParameters['name'] ?? '';
        return BlocProvider(
          create: (_) => sl<ItemsBloc>()..add(ItemsLoadRequested(listId)),
          child: ItemsPage(listId: listId, listName: listName),
        );
      },
    ),
    GoRoute(
      path: '/items/add/select-list',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ListsBloc>()..add(const ListsLoadRequested()),
        child: const SelectListPage(),
      ),
    ),
    GoRoute(
      path: '/items/add',
      redirect: (context, state) {
        final listId = state.uri.queryParameters['listId'] ?? '';
        if (listId.isEmpty) return '/items/add/select-list';
        return null;
      },
      builder: (context, state) {
        final listId = state.uri.queryParameters['listId']!;
        return AddItemPage(listId: listId);
      },
    ),
    GoRoute(
      path: '/items/add/form',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AiAnalysisCubit>()),
            BlocProvider(create: (_) => sl<CategoriesCubit>()..load()),
            BlocProvider(create: (_) => sl<ItemsBloc>()),
          ],
          child: AddItemFormPage(
            imagePath: extra['imagePath']!,
            listId: extra['listId']!,
          ),
        );
      },
    ),
    GoRoute(
      path: '/items/:id',
      builder: (context, state) {
        final item = state.extra as Item;
        return BlocProvider(
          create: (_) => ItemDetailBloc(
            item: item,
            updateItem: sl<UpdateItemUsecase>(),
            deleteItem: sl<DeleteItemUsecase>(),
          ),
          child: const ItemDetailPage(),
        );
      },
    ),
  ],
);
