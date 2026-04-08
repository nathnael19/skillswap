import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  const AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return left(ServerFailure('User is null!'));
      }
      return right(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return left(ServerFailure(e.message ?? 'Unknown error.'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return left(ServerFailure('User is null!'));
      }
      return right(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return left(ServerFailure(e.message ?? 'Unknown error.'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> currentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(ServerFailure('User not logged in.'));
      }
      return right(user.uid);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
