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
              method
              status
              date
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
          mutation MakePayment(\$saleId: String!, \$amount: Float!, \$method: String!) {
            makePayment(saleId: \$saleId, amount: \$amount, method: \$method) {
              paymentId
              saleId
              amount
              method
              status
              date
            }
          }
        '''),
        variables: {
          'saleId': paymentData['saleId'],
          'amount': paymentData['amount'],
          'method': paymentData['method'],
        },
      ),
    );
  }
}
