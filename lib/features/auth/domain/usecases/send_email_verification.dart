import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerification implements UseCase<void, NoParams> {
  final AuthRepository authRepository;
  const SendEmailVerification(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.sendEmailVerification();
  }
}
