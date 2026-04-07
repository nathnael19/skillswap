import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserSignUp _userSignUp;

  AuthCubit({
    required UserSignUp userSignUp,
  })  : _userSignUp = userSignUp,
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
}
