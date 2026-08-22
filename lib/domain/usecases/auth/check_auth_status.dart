import '../../repositories/auth_repository.dart';

/// UseCase to check if user is currently authenticated
class CheckAuthStatus {
  const CheckAuthStatus(this.repository);

  final AuthRepository repository;

  Future<bool> call() {
    return repository.isAuthenticated();
  }
}
