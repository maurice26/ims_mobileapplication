import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/supplier.dart';
import '../services/supplier_service.dart';
import 'auth_provider.dart';

final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final authState = ref.read(authProvider);
  if (authState == null || !authState.isAuthenticated) {
    return [];
  }
  final result = await SupplierService().getSuppliers(authState.token);
  if (result.hasException) throw result.exception!;
  final data = result.data?['suppliers'] as List<dynamic>? ?? [];
  return data
      .map((json) => Supplier.fromJson(json as Map<String, dynamic>))
      .toList();
});
