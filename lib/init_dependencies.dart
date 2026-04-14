import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/storage/firebase_storage_service.dart';
import 'package:skillswap/core/storage/storage_service.dart';
import 'package:skillswap/core/services/presence_service.dart';
import 'package:skillswap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_out.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/home/data/repositories/home_repository_impl.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/profile_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/master_profile_cubit.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/home/data/repositories/chat_repository_impl.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/firebase_options.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
  serviceLocator.registerLazySingleton(() => FirebaseStorage.instance);
  serviceLocator.registerLazySingleton(() => http.Client());

  serviceLocator.registerLazySingleton(
    () => ApiClient(
      serviceLocator<FirebaseAuth>(),
      serviceLocator<http.Client>(),
    ),
  );

  serviceLocator.registerLazySingleton<StorageService>(
    () => FirebaseStorageService(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => PresenceService.instance);

  _initAuth();
  _initHome();
  _initChat();
}

void _initAuth() {
  // Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<FirebaseAuth>(),
      serviceLocator<ApiClient>(),
    ),
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

void _initHome() {
  // Repository
  serviceLocator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      serviceLocator<ApiClient>(),
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://skillswap-887cc-default-rtdb.firebaseio.com',
      ),
    ),
  );

  // Cubits
  serviceLocator.registerFactory(
    () => DiscoveryCubit(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerFactory(
    () => MatchesCubit(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreditsCubit(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerFactory(
    () => ProfileCubit(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerFactory(
    () => LikesCubit(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerFactory(
    () => MasterProfileCubit(serviceLocator<HomeRepository>()),
  );
}

void _initChat() {
  // Repository
  serviceLocator.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      serviceLocator<ApiClient>(),
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://skillswap-887cc-default-rtdb.firebaseio.com',
      ),
    ),
  );

  // Cubits
  serviceLocator.registerFactory(
    () => ChatCubit(chatRepository: serviceLocator<ChatRepository>()),
  );
}
