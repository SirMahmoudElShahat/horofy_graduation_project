import 'package:dio/dio.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/app_apis.dart';
import '../models/child_model.dart';

abstract class ChildRemoteDataSource {
  Future<List<ChildModel>> getChildren();
  Future<ChildModel> createChild(ChildModel child);
  Future<ChildModel> updateChild(ChildModel child);
  Future<void> deleteChild(String remoteId);
}

class ChildRemoteDataSourceImpl implements ChildRemoteDataSource {
  final Dio dio;

  ChildRemoteDataSourceImpl({required this.dio});

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
  Future<List<ChildModel>> getChildren() async {
    final response = await dio.get(AppApis.getChildren, options: _authOptions);

    print('=== Get Children Response ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle nested response format
      var data = response.data;

      // First level unwrap: get the 'data' field
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      // Second level unwrap: if data has a nested 'data' field and is a list, use that
      if (data is Map && data.containsKey('data') && data['data'] is List) {
        data = data['data'];
      }

      final List<dynamic> childList;
      if (data is List) {
        childList = data;
      } else {
        childList = [];
      }

      print('Parsed Children Count: ${childList.length}');
      return childList
          .map((e) => ChildModel.fromRemoteJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(response.data['message'] ?? 'فشل تحميل الأطفال');
  }

  @override
  Future<ChildModel> createChild(ChildModel child) async {
    try {
      final response = await dio.post(
        AppApis.createChild,
        options: _authOptions,
        data: child.toRemoteJson(),
      );

      print('=== Create Child Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle nested response format: response.data['data']['data'] contains actual child data
        var data = response.data;

        // First level unwrap: get the 'data' field
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        // Second level unwrap: if data has a nested 'data' field, use that
        if (data is Map && data.containsKey('data') && data['data'] is Map) {
          data = data['data'];
        }

        if (data == null) {
          throw Exception('استجابة الخادم لا تحتوي على بيانات الطفل');
        }

        print('Parsed Data: $data');
        return ChildModel.fromRemoteJson(data as Map<String, dynamic>);
      }

      throw Exception(
        response.data['message'] ??
            'فشل إضافة الطفل (رمز: ${response.statusCode})',
      );
    } on DioException catch (e) {
      // Handle Dio specific errors
      print('=== Dio Exception ===');
      print('Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String errorMsg = 'فشل إضافة الطفل';
      if (e.response != null) {
        errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
      } else {
        errorMsg = e.message ?? errorMsg;
      }
      throw Exception(errorMsg);
    } catch (e) {
      print('=== General Exception ===');
      print('Error: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<ChildModel> updateChild(ChildModel child) async {
    if (child.remoteId == null) throw Exception('لا يوجد remoteId للطفل');

    // Server expects numeric id in path: PUT /api/children/{id}
    final numericId = int.tryParse(child.remoteId!);
    if (numericId == null)
      throw Exception('remoteId غير صالح: ${child.remoteId}');

    final response = await dio.put(
      // PUT not PATCH
      AppApis.updateChild(numericId.toString()),
      options: _authOptions,
      data: child.toRemoteJson(), // same body as create
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle nested response format: response.data['data'] contains actual child data
      var data = response.data;

      // First level unwrap: get the 'data' field
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      // Second level unwrap: if data has a nested 'data' field, use that
      if (data is Map && data.containsKey('data') && data['data'] is Map) {
        data = data['data'];
      }

      return ChildModel.fromRemoteJson(data as Map<String, dynamic>);
    }

    throw Exception(response.data['message'] ?? 'فشل تعديل الطفل');
  }

  @override
  Future<void> deleteChild(String remoteId) async {
    // Server expects numeric id in path: DELETE /api/children/{id}
    final numericId = int.tryParse(remoteId);
    if (numericId == null) throw Exception('remoteId غير صالح: $remoteId');

    try {
      final response = await dio.delete(
        AppApis.deleteChild(numericId.toString()),
        options: _authOptions,
      );

      // Accept 200, 201, or 204 as success
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'فشل حذف الطفل');
      }
    } on DioException catch (e) {
      String errorMsg = 'فشل حذف الطفل';
      if (e.response != null) {
        errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
      } else {
        errorMsg = e.message ?? errorMsg;
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
