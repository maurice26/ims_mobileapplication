import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';
import 'auth_provider.dart';

final salesProvider = FutureProvider<List<Sale>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState?.token;
  if (token == null) return [];
  final service = SalesService();
  final result = await service.getSales(token);
  if (result.hasException) {
    throw result.exception!;
  }
  final List<dynamic> salesJson = result.data?['sales'] ?? [];
  return salesJson.map((json) => Sale.fromJson(json)).toList();
});
