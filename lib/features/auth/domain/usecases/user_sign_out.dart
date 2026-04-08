import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class UserSignOut {
  final AuthRepository _authRepository;

  UserSignOut(this._authRepository);

  Future<Either<Failure, void>> call() async {
    return await _authRepository.logout();
  }
}
