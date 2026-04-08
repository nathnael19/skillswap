import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _authRepository;

  GetCurrentUser(this._authRepository);

  Future<Either<Failure, String>> call() async {
    return await _authRepository.currentUser();
  }
}
