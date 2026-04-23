import 'package:app/features/add/presentation/pages/add_page.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/items/presentation/pages/add_item_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_state_notifier.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/items/presentation/bloc/items_bloc.dart';
import '../../features/items/presentation/bloc/items_event.dart';
import '../../features/items/presentation/bloc/search_items_bloc.dart';
import '../../features/items/presentation/bloc/search_items_event.dart';
import '../../features/items/presentation/pages/items_page.dart';
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
      path: '/items/add',
      builder: (context, state) {
        return AddItemPage();
      },
    ),
  ],
);
