import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final authState = ref.read(authProvider);
  if (authState == null || !authState.isAuthenticated) {
    return [];
  }

  final result = await ProductService().getProducts(authState.token);
  if (result.hasException) throw result.exception!;

  final data = result.data?['products'] as List<dynamic>? ?? [];
  return data
      .map((json) => Product.fromJson(json as Map<String, dynamic>))
      .toList();
});
