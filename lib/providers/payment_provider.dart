import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState?.token;
  if (token == null) return [];
  final service = PaymentService();
  final result = await service.getPayments(token);
  if (result.hasException) {
    throw result.exception!;
  }
  final List<dynamic> paymentsJson = result.data?['payments'] ?? [];
  return paymentsJson.map((json) => Payment.fromJson(json)).toList();
});
