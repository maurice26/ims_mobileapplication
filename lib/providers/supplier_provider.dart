import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/supplier.dart';
import '../services/supplier_service.dart';
import 'auth_provider.dart';

final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState?.token;
  if (token == null) return [];
  final service = SupplierService();
  final result = await service.getSuppliers(token);
  if (result.hasException) {
    throw result.exception!;
  }
  final List<dynamic> suppliersJson = result.data?['suppliers'] ?? [];
  return suppliersJson.map((json) => Supplier.fromJson(json)).toList();
});
