import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}
