import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/sales_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/role_guard.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return RoleGuard(
      requiredRole: 'sales',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payments'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
        body: paymentsAsync.when(
          data: (payments) => ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                child: ListTile(
                  title: Text('Payment \$${payment.amount}'),
                  subtitle: Text('${payment.method} - ${payment.status}'),
                  trailing: Text(payment.date),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final authState = ref.read(authProvider);
            final token = authState?.token;
            if (token == null) return;

            final salesAsync = await ref.read(salesProvider.future);
            if (salesAsync.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No sales found to pay.')),
                );
              }
              return;
            }

            String? selectedSaleId = salesAsync.first.id;
            final amountController = TextEditingController(text: '');
            final methodController = TextEditingController(text: 'cash');

            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Make Payment'),
                content: StatefulBuilder(
                  builder: (context, setState) => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedSaleId,
                          items: salesAsync
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text('Sale ${s.id}'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedSaleId = v),
                          decoration: const InputDecoration(labelText: 'Sale'),
                        ),
                        TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: methodController,
                          decoration: const InputDecoration(
                            labelText: 'Method',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(
                        amountController.text.trim(),
                      );
                      final method = methodController.text.trim();
                      if (selectedSaleId == null ||
                          amount == null ||
                          amount <= 0 ||
                          method.isEmpty) {
                        return;
                      }

                      final res = await PaymentService().makePayment(token, {
                        'saleId': selectedSaleId!,
                        'amount': amount,
                        'method': method,
                      });

                      if (res.hasException) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Payment failed: ${res.exception}'),
                            ),
                          );
                        }
                        return;
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment recorded!')),
                        );
                      }
                      Navigator.pop(context);
                      ref.invalidate(paymentsProvider);
                    },
                    child: const Text('Pay'),
                  ),
                ],
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
