import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login({required String email, required String password}) =>
      remoteDataSource.login(email: email, password: password);

  @override
  Future<String> register({required String email, required String password}) =>
      remoteDataSource.register(email: email, password: password);

  @override
  Future<String> forgotPassword({required String email}) =>
      remoteDataSource.forgotPassword(email: email);

  @override
  Future<void> verifyOtp({required String email, required String otp}) =>
      remoteDataSource.verifyOtp(email: email, otp: otp);

  @override
  Future<void> resetPassword({required String email, required String otp, required String newPassword}) =>
      remoteDataSource.resetPassword(email: email, otp: otp, newPassword: newPassword);
}