import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final UserEntity user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class RegisterSuccess extends AuthState {
  final String otp;
  const RegisterSuccess(this.otp);
  @override
  List<Object?> get props => [otp];
}

class ForgotPasswordSuccess extends AuthState {
  final String otp;
  const ForgotPasswordSuccess(this.otp);
  @override
  List<Object?> get props => [otp];
}

class VerifyOtpSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
