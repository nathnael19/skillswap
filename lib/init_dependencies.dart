import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/cache/app_image_cache_manager.dart';
import 'package:skillswap/core/cache/local_cache_service.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/storage/supabase_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillswap/core/storage/storage_service.dart';
import 'package:skillswap/core/services/presence_service.dart';
import 'package:skillswap/core/network/connection_checker.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:skillswap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_out.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in_with_google.dart';
import 'package:skillswap/features/auth/domain/usecases/sync_fcm_token.dart';
import 'package:skillswap/features/auth/domain/usecases/remove_fcm_token.dart';
import 'package:skillswap/features/auth/domain/usecases/delete_account.dart';
import 'package:skillswap/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:skillswap/features/auth/domain/usecases/send_email_verification.dart';
import 'package:skillswap/features/auth/domain/usecases/check_email_verified.dart';
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
import 'package:skillswap/features/live_sessions/data/services/live_session_backend_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_service.dart';
import 'package:skillswap/features/live_sessions/presentation/cubit/live_session_cubit.dart';
import 'package:skillswap/features/hubs/data/services/hub_backend_service.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
  serviceLocator.registerLazySingleton(() => FirebaseStorage.instance);
  serviceLocator.registerLazySingleton(() => GoogleSignIn());
  serviceLocator.registerLazySingleton(() => Supabase.instance.client);
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => AppImageCacheManager.instance);
  serviceLocator.registerLazySingleton<LocalCacheService>(
    () => throw StateError('LocalCacheService not initialized'),
  );
  final localCacheService = await LocalCacheService.create();
  serviceLocator.unregister<LocalCacheService>();
  serviceLocator.registerLazySingleton<LocalCacheService>(
    () => localCacheService,
  );

  serviceLocator.registerLazySingleton(
    () => ApiClient(
      serviceLocator<FirebaseAuth>(),
      serviceLocator<http.Client>(),
    ),
  );

  serviceLocator.registerLazySingleton<StorageService>(
    () => SupabaseStorageService(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => PresenceService.instance);

  serviceLocator.registerLazySingleton<ConnectionChecker>(
    () => ConnectionCheckerImpl(Connectivity()),
  );

  serviceLocator.registerLazySingleton(
    () => ConnectivityCubit(serviceLocator<ConnectionChecker>()),
  );

  _initAuth();
  _initHome();
  _initChat();
  _initLiveSessions();
  _initHubs();
}

void _initAuth() {
  // Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<FirebaseAuth>(),
      serviceLocator<GoogleSignIn>(),
      serviceLocator<ApiClient>(),
    ),
  );

  // Usecases
  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignIn(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignInWithGoogle(serviceLocator()));
  serviceLocator.registerFactory(() => GetCurrentUser(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignOut(serviceLocator()));
  serviceLocator.registerFactory(() => SyncFcmToken(serviceLocator()));
  serviceLocator.registerFactory(() => RemoveFcmToken(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteAccount(serviceLocator()));
  serviceLocator.registerFactory(
    () => SendPasswordResetEmail(serviceLocator()),
  );
  serviceLocator.registerFactory(() => SendEmailVerification(serviceLocator()));
  serviceLocator.registerFactory(() => CheckEmailVerified(serviceLocator()));

  // Cubits
  serviceLocator.registerLazySingleton(
    () => AuthCubit(
      userSignUp: serviceLocator(),
      userSignIn: serviceLocator(),
      userSignInWithGoogle: serviceLocator(),
      getCurrentUser: serviceLocator(),
      userSignOut: serviceLocator(),
      syncFcmToken: serviceLocator(),
      removeFcmToken: serviceLocator(),
      deleteAccount: serviceLocator(),
      sendPasswordResetEmail: serviceLocator(),
      sendEmailVerification: serviceLocator(),
      checkEmailVerified: serviceLocator(),
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
        databaseURL: AppConstants.firebaseRtdbUrl,
      ),
      serviceLocator<StorageService>(),
      serviceLocator<LocalCacheService>(),
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
        databaseURL: AppConstants.firebaseRtdbUrl,
      ),
      serviceLocator<LocalCacheService>(),
    ),
  );

  // Cubits
  serviceLocator.registerFactory(
    () => ChatCubit(chatRepository: serviceLocator<ChatRepository>()),
  );
}

void _initLiveSessions() {
  serviceLocator.registerLazySingleton(() => LiveSessionService());
  serviceLocator.registerLazySingleton(
    () => LiveSessionBackendService(serviceLocator<ApiClient>()),
  );
  serviceLocator.registerLazySingleton(
    () => LiveSessionFirestoreService(
      serviceLocator<FirebaseFirestore>(),
      serviceLocator<FirebaseAuth>(),
    ),
  );

  serviceLocator.registerFactory(
    () => LiveSessionCubit(
      liveService: serviceLocator<LiveSessionService>(),
      backendService: serviceLocator<LiveSessionBackendService>(),
      firestoreService: serviceLocator<LiveSessionFirestoreService>(),
    ),
  );
}

void _initHubs() {
  serviceLocator.registerLazySingleton(
    () => HubBackendService(
      serviceLocator<ApiClient>(),
      serviceLocator<LocalCacheService>(),
    ),
  );
}
