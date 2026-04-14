import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_out.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/core/services/presence_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class AuthCubit extends Cubit<AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final GetCurrentUser _getCurrentUser;
  final UserSignOut _userSignOut;

  AuthCubit({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required GetCurrentUser getCurrentUser,
    required UserSignOut userSignOut,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        _getCurrentUser = getCurrentUser,
        _userSignOut = userSignOut,
        super(AuthInitial());

  void getUserData() async {
    final res = await _getCurrentUser();

    res.fold(
      (l) => emit(AuthInitial()),
      (r) {
        PresenceService.instance.goOnline(r);
        emit(AuthSuccess(r));
      },
    );
  }

  void signUp({
    required String name,
    required String email,
    required String password,
    String? bio,
    String? profession,
    String? location,
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
        skills: skills,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) {
        PresenceService.instance.goOnline(r);
        emit(AuthSuccess(r));
      },
    );
  }

  void signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final res = await _userSignIn(
      UserSignInParams(
        email: email,
        password: password,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) {
        PresenceService.instance.goOnline(r);
        emit(AuthSuccess(r));
      },
    );
  }

  void signOut() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      PresenceService.instance.goOffline(uid);
    }
    
    final res = await _userSignOut();

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthInitial()),
    );
  }
}
