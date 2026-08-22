import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC managing authentication state and actions.
/// Directly communicates with [AuthRepository] for simplicity and maintainability.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
  }) : super(AuthState.initial()) {
    on<SessionCheckRequested>(_onSessionCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  final AuthRepository authRepository;

  Future<void> _onSessionCheckRequested(
    SessionCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        final token = await authRepository.getAuthToken();
        final authUser = await authRepository.getAuthenticatedUser();
        final orgId = await authRepository.getOrgId();
        final role = await authRepository.getUserRole();
        
        emit(state.copyWith(
          status: AuthStatus.success,
          token: token,
          user: authUser,
          orgId: orgId,
          role: role,
        ));
      } else {
        // If not authenticated, we could be in 'initial' or 'empty' state.
        // For splash logic, 'empty' tells the UI to go to Login.
        emit(state.copyWith(status: AuthStatus.empty));
      }
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: 'Unable to restore session. Please login again.',
      ));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Basic validation
    if (event.email.isEmpty) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Email is required'));
      return;
    }
    if (!event.email.contains('@')) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Please enter a valid email'));
      return;
    }
    if (event.password.isEmpty) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Password is required'));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await authRepository.login(event.email, event.password);
      
      // Fetch the rest of the session info after successful login
      final authUser = await authRepository.getAuthenticatedUser();
      final orgId = await authRepository.getOrgId();
      final role = await authRepository.getUserRole();

      emit(state.copyWith(
        status: AuthStatus.success,
        token: response.accessToken,
        user: authUser,
        orgId: orgId,
        role: role,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Authentication failed. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.logout();
      emit(AuthState.initial().copyWith(status: AuthStatus.empty));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Logout failed'));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Note: Usually we don't set 'loading' for background refresh to avoid UI flickers,
    // but here we follow the prompt's expected state flow if needed.
    try {
      final response = await authRepository.refreshToken(event.refreshToken);
      if (response != null) {
        emit(state.copyWith(
          status: AuthStatus.success,
          token: response.accessToken,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error, 
          errorMessage: 'Session expired. Please login again.',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: 'Unable to refresh session',
      ));
    }
  }
}
