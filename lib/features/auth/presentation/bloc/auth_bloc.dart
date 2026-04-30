import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/auth/domain/usecases/login_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/logout_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/register_usecase.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_event.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _login;
  final RegisterUsecase _register;
  final LogoutUsecase _logout;
  final AuthStateNotifier _authStateNotifier;

  AuthBloc({
    required LoginUsecase login,
    required RegisterUsecase register,
    required LogoutUsecase logout,
    required AuthStateNotifier authStateNotifier,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _authStateNotifier = authStateNotifier,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _login(email: event.email, password: event.password);
      _authStateNotifier.setUserName(user.name);
      _authStateNotifier.setAuthenticated(true);
      emit(const AuthSuccess());
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      _authStateNotifier.setUserName(user.name);
      _authStateNotifier.setAuthenticated(true);
      emit(const AuthSuccess());
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logout();
      _authStateNotifier.setUserName(null);
      _authStateNotifier.setAuthenticated(false);
      emit(const AuthSuccess());
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    }
  }
}
