import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_service.dart';

class PaymentService {
  Future<QueryResult> getPayments(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql('''
          query {
            payments {
              paymentId
              saleId
              amount
              paymentMethod
              paymentStatus
              paymentDate
            }
          }
        '''),
      ),
    );
  }

  Future<QueryResult> makePayment(
    String token,
    Map<String, dynamic> paymentData,
  ) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql('''
          mutation AddPayment(\$saleId: Int!, \$amount: Decimal!, \$method: String!) {
            addPayment(saleId: \$saleId, amount: \$amount, method: \$method) {
              paymentId
              saleId
              amount
              paymentMethod
              paymentStatus
              paymentDate
            }
          }
        '''),
        variables: {
          'saleId':
              int.tryParse(paymentData['saleId'].toString()) ??
              paymentData['saleId'],
          'amount': (paymentData['amount'] as num).toDouble(),
          'method': paymentData['method'],
        },
      ),
    );
  }
}
