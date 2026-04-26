import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailVerified implements UseCase<bool, NoParams> {
  final AuthRepository authRepository;
  const CheckEmailVerified(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await authRepository.checkEmailVerified();
  }
}
