import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _apiClient;

  const AuthRepositoryImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._apiClient,
  );

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
  Future<Either<Failure, String>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(ServerFailure('Google sign in cancelled.'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return left(ServerFailure('User is null!'));
      }

      // If new user, initialize in backend
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final response = await _apiClient.post(
          ApiConstants.initUser,
          body: {
            'name': user.displayName ?? '',
            'email': user.email ?? '',
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          return left(ServerFailure(
              'Failed to initialize user in backend: ${response.body}'));
        }
      }

      return right(user.uid);
    } on FirebaseAuthException catch (e) {
      return left(ServerFailure(e.message ?? 'Unknown error.'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Sign out from the provider too, otherwise Android can "auto-pick"
      // the last account on the next sign-in.
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
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

  @override
  Future<Either<Failure, void>> removeFcmToken(String token) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateUser,
        body: {
          'fcm_tokens_remove': [token],
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(null);
      }
      return left(ServerFailure('Failed to remove FCM token'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final response = await _apiClient.delete(ApiConstants.deleteUser);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _firebaseAuth.signOut();
        return right(null);
      }
      return left(ServerFailure('Failed to delete account from server: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(ServerFailure(e.message ?? 'Unknown error.'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(ServerFailure('User not logged in.'));
      }
      // Reloading ensures we have the latest state and the user is properly signed in
      await user.reload();
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return left(ServerFailure('We sent too many emails recently. Please wait a moment and try again.'));
      }
      return left(ServerFailure(e.message ?? 'Unknown error.'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(ServerFailure('User not logged in.'));
      }
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      return right(updatedUser?.emailVerified ?? false);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
