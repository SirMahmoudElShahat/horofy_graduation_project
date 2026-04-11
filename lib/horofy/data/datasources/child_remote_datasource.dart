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
    final response = await dio.get(
      AppApis.getChildren,
      options: _authOptions,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => ChildModel.fromRemoteJson(e)).toList();
    }

    throw Exception(response.data['message'] ?? 'فشل تحميل الأطفال');
  }

  @override
  Future<ChildModel> createChild(ChildModel child) async {
    final response = await dio.post(
      AppApis.createChild,
      options: _authOptions,
      data: child.toRemoteJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChildModel.fromRemoteJson(response.data['data']);
    }

    throw Exception(response.data['message'] ?? 'فشل إضافة الطفل');
  }

  @override
  Future<ChildModel> updateChild(ChildModel child) async {
    if (child.remoteId == null) throw Exception('لا يوجد remoteId للطفل');

    // Server expects numeric id in path: PUT /api/children/{id}
    final numericId = int.tryParse(child.remoteId!);
    if (numericId == null) throw Exception('remoteId غير صالح: ${child.remoteId}');

    final response = await dio.put(                        // PUT not PATCH
      AppApis.updateChild(numericId.toString()),
      options: _authOptions,
      data: child.toRemoteJson(),                          // same body as create
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChildModel.fromRemoteJson(response.data['data']);
    }

    throw Exception(response.data['message'] ?? 'فشل تعديل الطفل');
  }

  @override
  Future<void> deleteChild(String remoteId) async {
    // Server expects numeric id in path: DELETE /api/children/{id}
    final numericId = int.tryParse(remoteId);
    if (numericId == null) throw Exception('remoteId غير صالح: $remoteId');

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
  }
}