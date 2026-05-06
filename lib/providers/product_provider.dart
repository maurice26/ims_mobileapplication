import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState?.token;
  if (token == null) return [];
  final service = ProductService();
  final result = await service.getProducts(token);
  if (result.hasException) {
    throw result.exception!;
  }
  // Parse products from GraphQL data
  final data = result.data?['products'] as List<dynamic>? ?? [];
  return data.map((json) => Product.fromJson(json)).toList();
});
