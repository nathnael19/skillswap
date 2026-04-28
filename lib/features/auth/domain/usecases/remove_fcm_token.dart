import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class RemoveFcmToken implements UseCase<void, RemoveFcmTokenParams> {
  final AuthRepository authRepository;

  RemoveFcmToken(this.authRepository);

  @override
  Future<Either<Failure, void>> call(RemoveFcmTokenParams params) async {
    return authRepository.removeFcmToken(params.token);
  }
}

class RemoveFcmTokenParams {
  final String token;

  RemoveFcmTokenParams(this.token);
}
