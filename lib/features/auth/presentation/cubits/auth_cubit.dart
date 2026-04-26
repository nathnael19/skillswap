import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_out.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/domain/usecases/sync_fcm_token.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in_with_google.dart';
import 'package:skillswap/features/auth/domain/usecases/delete_account.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/core/services/presence_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:skillswap/core/usecase/usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final UserSignInWithGoogle _userSignInWithGoogle;
  final GetCurrentUser _getCurrentUser;
  final UserSignOut _userSignOut;
  final SyncFcmToken _syncFcmToken;
  final DeleteAccount _deleteAccount;

  AuthCubit({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required UserSignInWithGoogle userSignInWithGoogle,
    required GetCurrentUser getCurrentUser,
    required UserSignOut userSignOut,
    required SyncFcmToken syncFcmToken,
    required DeleteAccount deleteAccount,
  }) : _userSignUp = userSignUp,
       _userSignIn = userSignIn,
       _userSignInWithGoogle = userSignInWithGoogle,
       _getCurrentUser = getCurrentUser,
       _userSignOut = userSignOut,
       _syncFcmToken = syncFcmToken,
       _deleteAccount = deleteAccount,
       super(AuthInitial());

  Future<void> _handleFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      print('[FCM] Permission status: ${settings.authorizationStatus}');

      // Web requires a VAPID key, other platforms do not
      final token = await messaging.getToken(
        vapidKey: kIsWeb ? AppConstants.fcmWebVapidKey : null,
      );

      if (token != null) {
        print('[FCM] Got token: $token');
        final result = await _syncFcmToken(SyncFcmTokenParams(token));
        result.fold(
          (failure) => print('[FCM] Sync failed: ${failure.message}'),
          (_) => print('[FCM] Token synced successfully!'),
        );
      } else {
        print(
          '[FCM] Token is null — on web, make sure your VAPID key is set in AppConstants.fcmWebVapidKey',
        );
      }
    } catch (e) {
      print('[FCM] Error: $e');
    }
  }

  void getUserData() async {
    final res = await _getCurrentUser();

    res.fold((l) => emit(AuthInitial()), (r) {
      PresenceService.instance.goOnline(r);
      _handleFcmToken();
      emit(AuthSuccess(r));
    });
  }

  void signUp({
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
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        email: email,
        password: password,
        name: name,
        bio: bio,
        profession: profession,
        location: location,
        primaryCategory: primaryCategory,
        expertiseLevel: expertiseLevel,
        skills: skills,
      ),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) {
      PresenceService.instance.goOnline(r);
      _handleFcmToken();
      emit(AuthSuccess(r));
    });
  }

  void signIn({required String email, required String password}) async {
    emit(AuthLoading());
    final res = await _userSignIn(
      UserSignInParams(email: email, password: password),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) {
      PresenceService.instance.goOnline(r);
      _handleFcmToken();
      emit(AuthSuccess(r));
    });
  }

  void signInWithGoogle() async {
    emit(AuthLoading());
    final res = await _userSignInWithGoogle(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) {
      PresenceService.instance.goOnline(r);
      _handleFcmToken();
      emit(AuthSuccess(r));
    });
  }

  void signOut() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      PresenceService.instance.goOffline(uid);
    }

    final res = await _userSignOut();

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthInitial()));
  }

  void deleteAccount() async {
    emit(AuthLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      PresenceService.instance.goOffline(uid);
    }
    
    final res = await _deleteAccount(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthInitial()),
    );
  }
}
