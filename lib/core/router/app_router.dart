import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_state_notifier.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/items/presentation/bloc/items_bloc.dart';
import '../../features/items/presentation/bloc/items_event.dart';
import '../../features/items/presentation/pages/items_page.dart';
import '../../features/lists/presentation/bloc/lists_bloc.dart';
import '../../features/lists/presentation/bloc/lists_event.dart';
import '../../features/lists/presentation/pages/lists_page.dart';

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
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
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
      path: '/lists/:id/items',
      builder: (context, state) {
        final listId = state.pathParameters['id']!;
        final listName = state.uri.queryParameters['name'] ?? '';
        return BlocProvider(
          create: (_) =>
              sl<ItemsBloc>()..add(ItemsLoadRequested(listId)),
          child: ItemsPage(listId: listId, listName: listName),
        );
      },
    ),
  ],
);
