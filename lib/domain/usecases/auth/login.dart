import '../../entities/mock_login_response.dart';
import '../../repositories/auth_repository.dart';

/// UseCase to log in with email and password
class Login {
  const Login(this.repository);

  final AuthRepository repository;

  Future<MockLoginResponse> call(String email, String password) {
    return repository.login(email, password);
  }
}
