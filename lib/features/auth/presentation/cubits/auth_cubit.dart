import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_in.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;

  AuthCubit({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        super(AuthInitial());

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        email: email,
        password: password,
        name: name,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthSuccess(r)),
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
      (r) => emit(AuthSuccess(r)),
    );
  }
}
