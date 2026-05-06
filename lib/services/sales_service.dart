import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/sale.dart';
import 'graphql_service.dart';

class SalesService {
  Future<QueryResult> getSales(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql('''
          query {
            sales {
              saleId
              productId
              quantity
              total
              date
              userId
            }
          }
        '''),
      ),
    );
  }

  Future<QueryResult> createSale(String token, Sale sale) async {
    final client = GraphQLService.client(token);

    return await client.mutate(
      MutationOptions(
        document: gql('''
          mutation CreateSale(\$productId: String!, \$quantity: Int!, \$total: Float!) {
            createSale(productId: \$productId, quantity: \$quantity, total: \$total) {
              saleId
              productId
              quantity
              total
              date
              userId
            }
          }
        '''),
        variables: {
          'productId': sale.productId,
          'quantity': sale.quantity,
          'total': sale.total,
        },
      ),
    );
  }
}
