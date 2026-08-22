import '../../entities/mock_login_response.dart';
import '../../repositories/auth_repository.dart';

/// UseCase to refresh auth token
class RefreshToken {
  const RefreshToken(this.repository);

  final AuthRepository repository;

  Future<MockLoginResponse?> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
