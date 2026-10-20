import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/category_models.dart';
import '../data/category_repository.dart';

final categoriesProvider = FutureProvider.autoDispose
    .family<List<CategoryItem>, String?>((ref, type) async {
      final repo = ref.watch(categoryRepositoryProvider);
      return repo.getCategories(type: type);
    });
