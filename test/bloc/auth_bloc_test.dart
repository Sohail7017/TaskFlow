import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/domain/entities/auth_credentials.dart';
import 'package:task_flow/domain/entities/mock_login_response.dart';
import 'package:task_flow/domain/entities/user.dart';
import 'package:task_flow/domain/entities/enums.dart';
import 'package:task_flow/domain/repositories/auth_repository.dart';
import 'package:task_flow/presentation/bloc/auth/auth_bloc.dart';
import 'package:task_flow/presentation/bloc/auth/auth_event.dart';
import 'package:task_flow/presentation/bloc/auth/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool isAuth = false;
  String? token;
  bool shouldThrowOnLogin = false;
  String? throwMessage;

  @override
  Future<bool> isAuthenticated() async => isAuth;

  @override
  Future<String?> getAuthToken() async => token;

  @override
  Future<String?> getOrgId() async => 'org_123';

  @override
  Future<User?> getAuthenticatedUser() async {
    if (!isAuth) return null;
    return const User(
      id: 'user_001',
      name: 'Test User',
      email: 'test@example.com',
      avatarUrl: '',
    );
  }

  @override
  Future<OrgRole?> getUserRole() async => OrgRole.member;

  @override
  Future<MockLoginResponse> login(String email, String password) async {
    if (shouldThrowOnLogin) {
      throw AuthenticationException(
        message: throwMessage ?? 'Invalid email or password.',
      );
    }
    isAuth = true;
    token = 'mock.access.token';
    return const MockLoginResponse(
      accessToken: 'mock.access.token',
      refreshToken: 'mock.refresh.token',
      accessTokenExpiresInSeconds: 900,
      refreshTokenExpiresInSeconds: 604800,
    );
  }

  @override
  Future<MockLoginResponse?> refreshToken(String refreshToken) async {
    if (refreshToken == 'valid.refresh.token') {
      token = 'new.mock.access.token';
      isAuth = true;
      return const MockLoginResponse(
        accessToken: 'new.mock.access.token',
        refreshToken: 'valid.refresh.token',
        accessTokenExpiresInSeconds: 900,
        refreshTokenExpiresInSeconds: 604800,
      );
    }
    isAuth = false;
    token = null;
    return null;
  }

  @override
  Future<List<AuthCredentials>> getTestCredentials() async => [];

  @override
  Future<void> logout() async {
    isAuth = false;
    token = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    authBloc = AuthBloc(authRepository: fakeAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
    });

    test('emits [loading, success] on successful LoginRequested', () async {
      final expected = [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.success,
          token: 'mock.access.token',
          user: User(
            id: 'user_001',
            name: 'Test User',
            email: 'test@example.com',
            avatarUrl: '',
          ),
          orgId: 'org_123',
          role: OrgRole.member,
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        const LoginRequested(
          email: 'ava.admin@nimbusdigital.test',
          password: 'Password123!',
        ),
      );
    });

    test('emits [loading, error] on failed LoginRequested', () async {
      fakeAuthRepository.shouldThrowOnLogin = true;
      fakeAuthRepository.throwMessage = 'Invalid email or password.';

      final expected = [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Invalid email or password.',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        const LoginRequested(
          email: 'ava.admin@nimbusdigital.test',
          password: 'WrongPassword',
        ),
      );
    });

    test('emits [loading, empty] on SessionCheckRequested when no session exists', () async {
      fakeAuthRepository.isAuth = false;

      final expected = [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.empty),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(const SessionCheckRequested());
    });

    test('emits [loading, success] on SessionCheckRequested when session is valid', () async {
      fakeAuthRepository.isAuth = true;

      final expected = [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.success,
          token: null, // Initial check in fake repopulates it if implemented, but here it's null unless we set it
          user: User(
            id: 'user_001',
            name: 'Test User',
            email: 'test@example.com',
            avatarUrl: '',
          ),
          orgId: 'org_123',
          role: OrgRole.member,
        ),
      ];
      
      // Setting token to match repository behavior if needed
      fakeAuthRepository.token = 'mock.access.token';
      expected[1] = expected[1].copyWith(token: 'mock.access.token');

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(const SessionCheckRequested());
    });

    test('emits [loading, empty] on LogoutRequested', () async {
      fakeAuthRepository.isAuth = true;

      final expected = [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.empty),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(const LogoutRequested());
    });

    test('emits [success] on RefreshTokenRequested with valid token', () async {
      final expected = [
        const AuthState(
          status: AuthStatus.success,
          token: 'new.mock.access.token',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        const RefreshTokenRequested(refreshToken: 'valid.refresh.token'),
      );
    });

    test('emits [loading, error] on RefreshTokenRequested with invalid token', () async {
      final expected = [
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Session expired. Please login again.',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        const RefreshTokenRequested(refreshToken: 'invalid.refresh.token'),
      );
    });
  });
}
