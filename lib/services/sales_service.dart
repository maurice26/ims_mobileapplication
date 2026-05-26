import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/sale.dart';
import 'graphql_service.dart';

class SalesService {
  Future<QueryResult> getSales(String token) async {
    final client = GraphQLService.client(token);

    return await client.query(
      QueryOptions(
        document: gql(r'''
          query {
            sales {
              saleId
              productId
              quantity
              totalPrice
              saleDate
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
        document: gql(r'''
          mutation CreateSale($input: SaleInput!) {
            createSale(input: $input) {
              saleId
              productId
              quantity
              totalPrice
              saleDate
              userId
            }
          }
        '''),
        variables: {
          'input': {
            'productId': int.parse(sale.productId),
            'userId': int.parse(sale.userId),
            'quantity': sale.quantity,
          },
        },
      ),
    );
  }
}
