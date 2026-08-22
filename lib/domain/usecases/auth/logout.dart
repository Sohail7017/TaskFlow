import '../../repositories/auth_repository.dart';

/// UseCase to log out current user
class Logout {
  const Logout(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.logout();
  }
}
