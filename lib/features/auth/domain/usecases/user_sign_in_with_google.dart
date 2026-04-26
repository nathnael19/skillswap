import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class UserSignInWithGoogle implements UseCase<String, NoParams> {
  final AuthRepository _authRepository;

  const UserSignInWithGoogle(this._authRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await _authRepository.signInWithGoogle();
  }
}
