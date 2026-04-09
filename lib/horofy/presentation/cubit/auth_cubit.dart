import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(email: email, password: password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final otp = await registerUseCase(email: email, password: password);
      emit(RegisterSuccess(otp));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());
    try {
      final otp = await forgotPasswordUseCase(email: email);
      emit(ForgotPasswordSuccess(otp));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(AuthLoading());
    try {
      await verifyOtpUseCase(email: email, otp: otp);
      emit(VerifyOtpSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    emit(AuthLoading());
    try {
      await resetPasswordUseCase(email: email, otp: otp, newPassword: newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}