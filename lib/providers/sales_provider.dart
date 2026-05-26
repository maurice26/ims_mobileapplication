import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';
import 'auth_provider.dart';

final salesProvider = FutureProvider<List<Sale>>((ref) async {
  final authState = ref.read(authProvider);
  if (authState == null || !authState.isAuthenticated) {
    return [];
  }
  final result = await SalesService().getSales(authState.token);
  if (result.hasException) throw result.exception!;
  final data = result.data?['sales'] as List<dynamic>? ?? [];
  return data
      .map((json) => Sale.fromJson(json as Map<String, dynamic>))
      .toList();
});
