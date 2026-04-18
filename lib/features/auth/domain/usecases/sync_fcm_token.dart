import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class SyncFcmToken implements UseCase<void, SyncFcmTokenParams> {
  final AuthRepository authRepository;

  SyncFcmToken(this.authRepository);

  @override
  Future<Either<Failure, void>> call(SyncFcmTokenParams params) async {
    return await authRepository.syncFcmToken(params.token);
  }
}

class SyncFcmTokenParams {
  final String token;

  SyncFcmTokenParams(this.token);
}
