import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';

abstract class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
