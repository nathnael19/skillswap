import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/usecase/usecase.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class UserSignUp implements UseCase<String, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, String>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      bio: params.bio,
      profession: params.profession,
      location: params.location,
      skills: params.skills,
    );
  }
}

class UserSignUpParams {
  final String email;
  final String password;
  final String name;
  final String? bio;
  final String? profession;
  final String? location;
  final List<Map<String, dynamic>>? skills;

  UserSignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.bio,
    this.profession,
    this.location,
    this.skills,
  });
}
