import 'package:circulari/features/add/presentation/pages/add_page.dart';
import 'package:flutter/material.dart';
import 'package:circulari/features/home/presentation/pages/home_page.dart';
import 'package:circulari/features/items/presentation/pages/add_item_form_args.dart';
import 'package:circulari/features/items/presentation/pages/add_item_form_page.dart';
import 'package:circulari/features/items/presentation/pages/add_item_picture_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/di/injection.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:circulari/features/auth/presentation/bloc/recovery_bloc.dart';
import 'package:circulari/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:circulari/features/auth/presentation/pages/login_page.dart';
import 'package:circulari/features/auth/presentation/pages/recovery_route_args.dart';
import 'package:circulari/features/auth/presentation/pages/register_page.dart';
import 'package:circulari/features/auth/presentation/pages/reset_password_page.dart';
import 'package:circulari/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/ai_analysis_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/categories_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_event.dart';
import 'package:circulari/features/items/presentation/pages/item_detail_page.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/presentation/pages/list_detail_page.dart';
import 'package:circulari/features/lists/presentation/utils/list_picture_map.dart';
import 'package:circulari/features/items/presentation/pages/select_list_page.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_event.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_event.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_cubit.dart';
import 'package:circulari/features/lists/presentation/pages/create_list_page.dart';
import 'package:circulari/features/lists/presentation/pages/lists_page.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_bloc.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_event.dart';
import 'package:circulari/features/profile/presentation/pages/profile_page.dart';
import 'package:circulari/features/splash/presentation/pages/splash_page.dart';
import 'package:circulari/core/router/scaffold_with_navbar.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: sl<AuthStateNotifier>(),
  redirect: (context, state) {
    final notifier = sl<AuthStateNotifier>();
    if (notifier.isInitializing) return null;

    final isAuthenticated = notifier.isAuthenticated;
    final isSplash = state.matchedLocation == '/splash';
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (isSplash) return isAuthenticated ? '/home' : '/auth/login';
    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
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
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<RecoveryBloc>(),
        child: const ForgotPasswordPage(),
      ),
    ),
    GoRoute(
      path: '/auth/verify-otp',
      builder: (context, state) {
        final args = state.extra as VerifyOtpArgs;
        return BlocProvider(
          create: (_) => sl<RecoveryBloc>(),
          child: VerifyOtpPage(args: args),
        );
      },
    ),
    GoRoute(
      path: '/auth/reset-password',
      builder: (context, state) {
        final args = state.extra as ResetPasswordArgs;
        return BlocProvider(
          create: (_) => sl<RecoveryBloc>(),
          child: ResetPasswordPage(args: args),
        );
      },
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
            child: const ListsPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<PlanBloc>()..add(const PlanLoadRequested()),
              ),
              BlocProvider(create: (_) => sl<AuthBloc>()),
            ],
            child: const ProfilePage(),
          ),
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
    GoRoute(
      path: '/lists/:id/items',
      builder: (context, state) {
        final listId = state.pathParameters['id']!;
        final list = state.extra as ItemList?;
        final picturePath = list != null ? assetForSlug(list.picture.slug) : null;
        final backgroundColor = list != null
            ? Color(int.parse(list.color.hexCode.replaceFirst('#', '0xff')))
            : null;
        return BlocProvider(
          create: (_) => sl<ItemsBloc>()..add(ItemsLoadRequested(listId)),
          child: ListDetailPage(
            listId: listId,
            listName: list?.name ?? '',
            picturePath: picturePath,
            backgroundColor: backgroundColor,
            initialTotalValue: list?.totalValue,
            seed: list?.picture.slug.hashCode,
            list: list,
          ),
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
        final list = state.extra as ItemList?;
        return AddItemPicturePage(listId: listId, list: list);
      },
    ),
    GoRoute(
      path: '/items/add/form',
      builder: (context, state) {
        final args = state.extra as AddItemFormArgs;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AiAnalysisCubit>()),
            BlocProvider(create: (_) => sl<CategoriesCubit>()..load()),
            BlocProvider(create: (_) => sl<ItemsBloc>()),
          ],
          child: AddItemFormPage(
            imagePath: args.imagePath,
            listId: args.listId,
            list: args.list,
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
