import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final authState = ref.read(authProvider); // ✅ fixed: watch → read
  if (authState == null || !authState.isAuthenticated) {
    return [];
  }
  final result = await PaymentService().getPayments(authState.token);
  if (result.hasException) throw result.exception!;
  final data = result.data?['payments'] as List<dynamic>? ?? [];
  return data
      .map((json) => Payment.fromJson(json as Map<String, dynamic>))
      .toList();
});
