import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_out.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/firebase_options.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);

  _initAuth();
}

void _initAuth() {
  // Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator()),
  );

  // Usecases
  serviceLocator.registerFactory(
    () => UserSignUp(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UserSignIn(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => GetCurrentUser(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UserSignOut(serviceLocator()),
  );

  // Cubits
  serviceLocator.registerLazySingleton(
    () => AuthCubit(
      userSignUp: serviceLocator(),
      userSignIn: serviceLocator(),
      getCurrentUser: serviceLocator(),
      userSignOut: serviceLocator(),
    ),
  );
}
