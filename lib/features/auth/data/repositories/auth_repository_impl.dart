import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final ApiClient _apiClient;

  const AuthRepositoryImpl(this._firebaseAuth, this._apiClient);

  @override
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? bio,
    String? profession,
    String? location,
    String? primaryCategory,
    String? expertiseLevel,
    List<Map<String, dynamic>>? skills,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return left(ServerFailure('User is null!'));
      }

      // Initialize user in our backend
      final response = await _apiClient.post(
        ApiConstants.initUser,
        body: {
          'name': name,
          'email': email,
          'bio': bio,
          'profession': profession,
          'location': location,
          'primary_category': primaryCategory,
          'expertise_level': expertiseLevel,
          'skills': skills,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return left(ServerFailure('Failed to initialize user in backend: ${response.body}'));
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

  @override
  Future<Either<Failure, void>> syncFcmToken(String token) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateUser,
        body: {
          'fcm_tokens': [token],
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(null);
      }
      return left(ServerFailure('Failed to sync FCM token'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
