import 'package:dio/dio.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/app_apis.dart';
import '../models/submission_model.dart';

abstract class SubmissionRemoteDataSource {
  Future<SubmissionModel> createSubmission(SubmissionModel submission);
  Future<List<SubmissionModel>> getChildSubmissions(int childId);
}

class SubmissionRemoteDataSourceImpl implements SubmissionRemoteDataSource {
  final Dio dio;

  SubmissionRemoteDataSourceImpl({required this.dio});

  Options get _authOptions {
    final token = CacheHelper.getString('accessToken') ?? '';
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await dio.post(
      AppApis.submitExercise,
      options: _authOptions,
      data: submission.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return SubmissionModel.fromJson(data);
      }
      // Server returned success with no body — return the sent model as-is
      return submission;
    }

    throw Exception(response.data['message'] ?? 'فشل إرسال النتيجة');
  }

  @override
  Future<List<SubmissionModel>> getChildSubmissions(int childId) async {
    final response = await dio.get(
      AppApis.getChildSubmissions(childId.toString()),
      options: _authOptions,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.data['data'];
      // Unwrap nested data if needed
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SubmissionModel.fromJson)
            .toList();
      }
      return [];
    }

    throw Exception(response.data['message'] ?? 'فشل تحميل النتائج');
  }
}