import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<UserEntity> call({required String email, required String password}) =>
      repository.login(email: email, password: password);
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  Future<String> call({required String email, required String password}) =>
      repository.register(email: email, password: password);
}

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);
  Future<String> call({required String email}) =>
      repository.forgotPassword(email: email);
}

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);
  Future<void> call({required String email, required String otp}) =>
      repository.verifyOtp(email: email, otp: otp);
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);
  Future<void> call({required String email, required String otp, required String newPassword}) =>
      repository.resetPassword(email: email, otp: otp, newPassword: newPassword);
}