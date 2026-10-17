import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'category_models.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(dioProvider));
});

class CategoryRepository {
  CategoryRepository(this._dio);

  final Dio _dio;

  Future<List<CategoryItem>> getCategories({String? type}) async {
    final response = await _dio.get<List<dynamic>>(
      'categories',
      queryParameters: type != null ? {'type': type} : null,
    );
    final data = response.data ?? <dynamic>[];
    return data
        .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryItem> createCategory(CreateCategoryDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'categories',
      data: dto.toJson(),
    );
    return CategoryItem.fromJson(response.data!);
  }

  Future<CategoryItem> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'categories/$id',
      data: {'name': ?name, 'icon': ?icon, 'color': ?color},
    );
    return CategoryItem.fromJson(response.data!);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<void>('categories/$id');
  }
}
