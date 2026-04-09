import 'package:dio/dio.dart';
import '../../../../core/constants/app_apis.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<String> register({
    required String email,
    required String password,
  });
  Future<String> forgotPassword({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  void _handleError(Response response) {
    final message = response.data['message'] ?? 'حدث خطأ، حاول تاني';
    throw Exception(message);
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      AppApis.login,
      options: Options(headers: _headers),
      data: {'email': email, 'password': password},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(response.data);
    }
    _handleError(response);
    throw Exception();
  }

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      AppApis.register,
      options: Options(headers: _headers),
      data: {
        'email': email,
        'password': password,
        'role': 'parent',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      _handleError(response);
    }
    final otp = response.data['data']['devOnlyOtp'] as String;
    return otp;
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final response = await dio.post(
      AppApis.forgotPassword,
      options: Options(headers: _headers),
      data: {'email': email},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      _handleError(response);
    }
    final otp = response.data['data']['devOnlyOtp'] as String;
    return otp;
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await dio.post(
      AppApis.verifyOtp,
      options: Options(headers: _headers),
      data: {'email': email, 'otp': otp},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      _handleError(response);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await dio.post(
      AppApis.resetPassword,
      options: Options(headers: _headers),
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      _handleError(response);
    }
  }
}
